class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :users]

  # GET /contacts
  def index
    @search = params[:search]
    @orders = [%w[Name name], %w[Kind kind_id], %w[Company company_id]]

    @contacts = current_user
                .contacts
                .includes(:address, :kind, :company)
                .left_joins(:phones)
                .select('contacts.*, count(*) as phones_count')
                .group('contacts.id')
    # .order(:name)
    # .order('kinds.description', :name)
    # .order(phones_count: :desc)

    if @search
      @contacts = @contacts.where(kind_id: @search[:kind_id]) if @search.key?(:kind_id) && !@search[:kind_id].blank?
      @contacts = @contacts.where(company_id: @search[:company_id]) if @search.key?(:company_id) && !@search[:company_id].blank?
      @contacts = @contacts.where('contacts.name LIKE ?', "%#{@search[:name]}%") if @search.key?(:name) && !@search[:name].blank?
      if @search.key?(:order) && !@search[:order].blank?
        order = @search[:order].to_sym
        order = case order
                when :kind_id
                  'kinds.description'
                when :company_id
                  'companies.name'
                else
                  :name
                end
        @contacts = @contacts.order(order)
      end
    end
  end

  # GET /contacts/1
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  def create
    @contact = Contact.new(contact_params)
    @contact.users << current_user

    if @contact.save
      redirect_to @contact, notice: 'Contact was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /contacts/1
  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: 'Contact was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /contacts/1
  def destroy
    @contact.destroy
    redirect_to contacts_url, notice: 'Contact was successfully destroyed.'
  end

  def users
    user = User.find(params[:user_id])
    @contact.users << user
    redirect_to @contact
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = current_user.contacts.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def contact_params
    params.require(:contact).permit(:name, :email, :remark, :kind_id, :company_id)
  end
end

class Dashboard::ContactsController < Dashboard::AdminController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @contacts = current_account.contacts.page(params[:page])
  end

  def show
    @contact_village = Pumi::Village.find_by_id(@contact.village_id)
  end

  def new
    @contact = Contact.new
  end

  def edit; end

  def create
    @contact = current_account.contacts.build(contact_params)

    if @contact.save
      redirect_to dashboard_contact_url(@contact), notice: 'Contact was successfully created.'
    else
      render :new
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to dashboard_contact_url(@contact), notice: 'Contact was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @contact.destroy

    redirect_to dashboard_contacts_url, notice: 'Contact was successfully destroyed.'
  end

  private

  def set_contact
    @contact = current_account.contacts.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :id, :msisdn, :province_id, :district_id, :commune_id,
      :village_id
    )
  end
end

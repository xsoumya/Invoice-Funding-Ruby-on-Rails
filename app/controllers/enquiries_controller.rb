class EnquiriesController < ApplicationController
  def new
    @enquiry = Enquiry.new
  end

  def create
    @enquiry = Enquiry.new(enquiry_params)

    if @enquiry.save
      redirect_to new_enquiry_path, notice: "Thanks, #{@enquiry.first_name}. We will be in touch shortly."
    else
      render :new
    end
  end

  private

  def enquiry_params
    params.require(:enquiry).permit(:first_name, :last_name, :email, :phone, :company, :enquiry_type, :message)
  end
end

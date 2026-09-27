class CreateEnquiries < ActiveRecord::Migration[6.1]
  def change
    create_table :enquiries do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :company
      t.string :enquiry_type, null: false
      t.text :message, null: false
      t.timestamps
    end
  end
end

class CreateFreelancers < ActiveRecord::Migration[7.1]
  def change
    create_table :freelancers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :source
      t.string :notes
      t.datetime :start_date, null: false
      t.datetime :end_date, null: true

      t.timestamps
    end
  end
end

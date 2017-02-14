class CreateDummys < ActiveRecord::Migration
  def change
    create_table :dummys do |t|

      t.timestamps null: false
    end
  end
end

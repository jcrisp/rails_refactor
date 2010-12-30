class CreateDummyModels < ActiveRecord::Migration
  def self.up
    create_table :dummy_models do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :dummy_models
  end
end

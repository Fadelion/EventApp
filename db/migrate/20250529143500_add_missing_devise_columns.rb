class AddMissingDeviseColumns < ActiveRecord::Migration[8.0]
  def change
    # Vérifier si les colonnes existent déjà avant de les ajouter
    unless column_exists?(:users, :confirmation_token)
      add_column :users, :confirmation_token, :string
    end
    
    unless column_exists?(:users, :confirmed_at)
      add_column :users, :confirmed_at, :datetime
    end
    
    unless column_exists?(:users, :confirmation_sent_at)
      add_column :users, :confirmation_sent_at, :datetime
    end
    
    unless column_exists?(:users, :unconfirmed_email)
      add_column :users, :unconfirmed_email, :string
    end
    
    unless column_exists?(:users, :failed_attempts)
      add_column :users, :failed_attempts, :integer, default: 0, null: false
    end
    
    unless column_exists?(:users, :unlock_token)
      add_column :users, :unlock_token, :string
    end
    
    unless column_exists?(:users, :locked_at)
      add_column :users, :locked_at, :datetime
    end
    
    # Ajouter les index s'ils n'existent pas
    unless index_exists?(:users, :confirmation_token)
      add_index :users, :confirmation_token, unique: true
    end
    
    unless index_exists?(:users, :unlock_token)
      add_index :users, :unlock_token, unique: true
    end
  end
end
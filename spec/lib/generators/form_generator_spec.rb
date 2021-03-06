require 'spec_helper'

require 'generators/rom/form_generator'

describe ROM::Generators::FormGenerator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before(:each) do
    prepare_destination
  end

  shared_examples_for "generates a base user form" do
    it "populates a base form file" do
      expect(destination_root).to have_structure {
        directory 'app' do
          directory 'forms' do
            file 'user_form.rb' do
              contains <<-CONTENT.strip_heredoc
              class UserForm < ROM::Model::Form

                input do
                  set_model_name 'User'

                  # define always-present form input attributes
                  # attribute :name, String
                end

                validations do
                  relation :users

                  # Add invariant form validations
                  # validates :name, presence: true
                end

              end
              CONTENT
            end
          end
        end
      }
    end
  end

  shared_examples_for "generates a create user form" do
    it "populates a create form file" do
      expect(destination_root).to have_structure {
        directory 'app' do
          directory 'forms' do
            file 'new_user_form.rb' do
              contains <<-CONTENT.strip_heredoc
              class NewUserForm < UserForm
                commands users: :create

                input do
                  # define form input attributes
                  # attribute :name, String

                  timestamps
                end

                validations do
                  # Add form validations
                  # validates :name, presence: true
                end

                def commit!
                  users.try { users.create.call(attributes) }
                end

              end
              CONTENT
            end
          end
        end
      }
    end
  end

  shared_examples_for "generates an edit user form" do

    it "populates a edit form file" do
      expect(destination_root).to have_structure {
        directory 'app' do
          directory 'forms' do
            file 'edit_user_form.rb' do
              contains <<-CONTENT.strip_heredoc
              class EditUserForm < UserForm
                commands users: :update

                input do
                  # define form input attributes
                  # attribute :name, String

                  timestamps :updated_at
                end

                validations do
                  # Add form validations
                  # validates :name, presence: true
                end

                def commit!
                  users.try { users.update.by_id(id).set(attributes) }
                end

              end
              CONTENT
            end
          end
        end
      }
    end
  end

  describe "rom:form users" do
    before do
      run_generator ['users']
    end

    it_should_behave_like "generates a create user form"
    it_should_behave_like "generates an edit user form"
  end

  describe "rom:form users --command=create" do
    before do
      run_generator ['users', '--command=create']
    end

    it_should_behave_like "generates a base user form"
    it_should_behave_like "generates a create user form"
  end

  describe "rom:form users --command=update" do
    before do
      run_generator ['users', '--command=update']
    end

    it_should_behave_like "generates a base user form"
    it_should_behave_like "generates an edit user form"
  end


end

require 'rails_helper'

RSpec.describe 'Admin Merchant Edit', type: :feature do
  before :each do
    admin = create(:admin)
    @merchant = create(:merchant)
    @inactive_merchant = create(:inactive_merchant)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
  end

  it 'allows admin to enable an inactive merchant' do
    visit merchants_path

    within "#merchant-#{@inactive_merchant.id}" do
      click_button 'Enable'
    end
    expect(current_path).to eq(merchants_path)

    within "#merchant-#{@inactive_merchant.id}" do
      expect(page).to have_button('Disable')
    end
  end
  it 'allows admin to disable an active merchant' do
    visit merchants_path

    within "#merchant-#{@merchant.id}" do
      click_button 'Disable'
    end
    expect(current_path).to eq(merchants_path)

    within "#merchant-#{@merchant.id}" do
      expect(page).to have_button('Enable')
    end
  end
end

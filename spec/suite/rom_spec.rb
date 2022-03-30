# frozen_string_literal: true

RSpec.describe ROM do
  it "allows an inline setup" do
    rom = ROM(:memory) do |setup|
      setup.relation(:users)
    end

    expect(rom.gateways[:default]).to be_a(ROM::Memory::Gateway)
  end

  it "allows an inline setup with configuration customization" do
    rom = ROM(:memory) do |setup, config|
      config.relation.infer_id_from_class = true

      setup.relation(:users)
    end

    expect(rom.gateways[:default]).to be_a(ROM::Memory::Gateway)
    expect(rom.relations[:users].config.component.infer_id_from_class).to be(true)
  end

  it "allows a multi-step setup" do
    setup = ROM(:memory)
    setup.relation(:users)

    rom = setup.finalize

    expect(rom.gateways[:default]).to be_a(ROM::Memory::Gateway)
  end
end

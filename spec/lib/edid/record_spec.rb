# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe EDID::Record do
  FILES_DIR = File.expand_path('../../fixtures/files', __dir__)

  let(:record) { described_class.read io }

  context 'with an ASUS PB278q monitor' do
    let(:io) { File.open "#{FILES_DIR}/edid_asus_pb278q" }

    describe '#manufacturer' do
      it { expect(record.manufacturer).to eq 'ACI' }
    end

    describe '#manufacture_year_real' do
      it { expect(record.manufacture_year_real).to eq 2014 }
    end

    describe '#video_interface' do
      it { expect(record.video_interface).to eq 'DisplayPort' }
    end

    describe '#to_s' do
      let(:expected_string) do
        <<~STRING
          Manufacturer: ACI
          Product: 10147
          Serial: 3173
          Manufacture_year: 2014
          Manufacture_week: 6
          EDID 1.4

          Digital input? true
          Bit depth: 8
          Video Interface: DisplayPort
          White and sync levels relative to blank: +0.7/−0.3 V

          Horizontal screen size: 34 cm
          Vertical screen size: 120 cm
          Display gamma: 58

          DPMS standby: yes
          DPMS suspend: no
          DPMS active-off: yes
          Display type: RGB 4:4:4
          Analog type: Monochrome or Grayscale

          X Resolution: 1784

          Checksum: 17
        STRING
      end

      it { expect(record.to_s).to eq expected_string }
    end
  end
end

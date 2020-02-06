# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe EDID::Record do
  FILES_DIR = File.expand_path('../../fixtures/files', __dir__)

  let(:record) { described_class.read io }

  context 'with an ASUS PB278q monitor' do
    let(:io) { File.open "#{FILES_DIR}/edid_asus_pb278q" }

    describe '#display_name' do
      it { expect(record.display_name).to eq 'ASUS PB278' }
    end

    describe '#display_serial_number' do
      it { expect(record.display_serial_number).to eq 'E2LMTF003173' }
    end

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

          Horizontal screen size: 60 cm
          Vertical screen size: 34 cm
          Display gamma: 120

          DPMS standby: no
          DPMS suspend: no
          DPMS active-off: yes
          Display type: RGB 4:4:4 + YCrCb 4:4:4 + YCrCb 4:2:2
          Analog type: unknown

          Descriptors:
            Display serial number: E2LMTF003173
            Display name: ASUS PB278

          Checksum: 242
        STRING
      end

      it { expect(record.to_s).to eq expected_string }
    end
  end
end

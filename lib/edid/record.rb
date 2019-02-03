# frozen_string_literal: true

##
# Read a Extended Display Identification Data record.
# https://en.wikipedia.org/wiki/Extended_Display_Identification_Data#EDID_1.4_data_format

module EDID
  class Record < BinData::Record
    ANALOG_DISPLAY_TYPES = { 0 => 'Monochrome or Grayscale', 1 => 'RGB color', 2 => 'Non-RGB color' }
    BIT_DEPTHS = { 1 => 6, 2 => 8, 3 => 10, 4 => 12, 5 => 14, 6 => 16 }
    DIGITAL_DISPLAY_TYPES = { 0 => 'RGB 4:4:4',
                              1 => 'RGB 4:4:4 + YCrCb 4:4:4',
                              2 => 'RGB 4:4:4 + YCrCb 4:2:2',
                              3 => 'RGB 4:4:4 + YCrCb 4:4:4 + YCrCb 4:2:2' }
    VIDEO_INTERFACES = { 1 => 'HDMIa', 2 => 'HDMIb', 4 => 'MDDI', 5 => 'DisplayPort' }
    VIDEO_WHITE_AND_SYNC_LEVELS = { 0 => '+0.7/−0.3 V', 1 => '+0.714/−0.286 V', 2 => '+1.0/−0.4 V',
                                    3 => '+0.7/0 V' }

    HEADER_BYTES = [0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00]
    array :header_bytes, type: :uint8, initial_length: 8, value: HEADER_BYTES, assert_value: HEADER_BYTES
    bit1 :manufacturer_id_pad, value: 0
    array :manufacturer_id, type: :bit5, initial_length: 3
    uint16le :product_code
    uint32le :serial_number
    uint8 :manufacture_week
    uint8 :manufacture_year
    uint8 :edid_version, initial_value: 1
    uint8 :edid_revision, initial_value: 3

    struct :video_input_parameters do
      bit1 :digital_inputs_switch
      bit3 :bit_depth_code, onlyif: :digital_inputs?
      bit4 :video_interface_code, onlyif: :digital_inputs?

      bit1 :analog_inputs_switch
      bit3 :white_sync_levels_code, onlyif: :analog_inputs?
      bit1 :blank_to_blank_setup_expected_switch
      bit1 :separate_sync_supported_switch
      bit1 :composite_sync_supported_switch
      bit1 :vsync_pulse_required_switch
    end

    uint8 :horizontal_screen_size_in_cm
    uint8 :vertical_screen_size_in_cm
    uint8 :display_gamma_raw

    struct :supported_features do
      bit1 :dpms_standby_support_bit
      bit1 :dpms_suspend_support_bit
      bit1 :dpms_active_off_support_bit
      bit2 :display_type_digital_bits
      bit2 :display_type_analog_bits
      bit1 :standard_srgb_color_space_switch
      bit1 :preferred_timing_mode_specified_in_descriptor_block_1_switch
      bit1 :continuous_timings_with_gtf_or_cvt_switch
    end

    struct :chromaticity_coordinates do
      bit2 :red_x_value_least_significant_bits
      bit2 :red_y_value_least_significant_bits
      bit2 :green_x_value_least_significant_bits
      bit2 :green_y_value_least_significant_bits
      bit2 :blue_and_white_least_significant_bits

      bit8 :red_x_value_most_significant_8_bits
      bit8 :red_y_value_most_significant_8_bits
      bit8 :green_x_value_most_significant_8_bits
      bit8 :green_y_value_most_significant_8_bits
      bit8 :blue_x_value_most_significant_8_bits
      bit8 :blue_y_value_most_significant_8_bits
      bit8 :default_white_point_x_most_significant_8_bits
      bit8 :default_white_point_y_most_significant_8_bits
    end

    array :established_timings_list_1, type: :bit1, initial_length: 8
    array :established_timings_list_2, type: :bit1, initial_length: 8
    array :established_timings_list_3, type: :bit1, initial_length: 8

    def analog_display_type
      ANALOG_DISPLAY_TYPES.fetch supported_features[:display_type_analog_bits], 'unknown'
    end

    def bit_depth
      BIT_DEPTHS.fetch video_input_parameters[:bit_depth_code], 'undefined'
    end

    def digital_display_type
      DIGITAL_DISPLAY_TYPES.fetch supported_features[:display_type_digital_bits], 'unknown'
    end

    def manufacturer
      manufacturer_id.map { |int| (int+64).chr }.join
    end

    def manufacture_year_real
      manufacture_week == 255 ? manufacture_year : (manufacture_year + 1990)
    end

    def video_interface
      VIDEO_INTERFACES.fetch video_input_parameters[:video_interface_code], 'undefined'
    end

    def white_sync_levels
      VIDEO_WHITE_AND_SYNC_LEVELS.fetch video_input_parameters[:white_sync_levels_code], 'unknown'
    end

    def to_s
      <<~MESSAGE
        Manufacturer: #{manufacturer}
        Product: #{product_code}
        Serial: #{serial_number}
        Manufacture_year: #{manufacture_year_real}
        Manufacture_week: #{manufacture_week == 255 ? 'unknown' : manufacture_week}

        Digital input? #{digital_inputs?}
        Bit depth: #{bit_depth}
        Video Interface: #{video_interface}
        Analog input? #{analog_inputs?}
        White and sync levels relative to blank: #{white_sync_levels}

        Horizontal screen size: #{horizontal_screen_size_in_cm} cm
        Vertical screen size: #{vertical_screen_size_in_cm} cm
        Display gamma: #{display_gamma_raw}

        DPMS standby: #{supported_features[:dpms_standby_support_bit] == 1 ? 'yes' : 'no'}
        DPMS suspend: #{supported_features[:dpms_suspend_support_bit] == 1 ? 'yes' : 'no'}
        DPMS active-off: #{supported_features[:dpms_active_off_support_bit] == 1 ? 'yes' : 'no'}
        Display type: #{digital_display_type}
        Analog type: #{analog_display_type}
      MESSAGE
    end

    private

    def analog_inputs?
      video_input_parameters[:analog_inputs_switch] == 0
    end

    def digital_inputs?
      video_input_parameters[:digital_inputs_switch] == 1
    end
  end
end

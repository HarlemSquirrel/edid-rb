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

    # Bytes 0-19 Header information
    array :header_bytes, type: :uint8, initial_length: 8, value: HEADER_BYTES, assert_value: HEADER_BYTES
    bit1 :manufacturer_id_pad, value: 0
    array :manufacturer_id, type: :bit5, initial_length: 3
    uint16le :product_code
    uint32le :serial_number
    uint8 :manufacture_week
    uint8 :manufacture_year
    uint8 :edid_version, initial_value: 1
    uint8 :edid_revision, initial_value: 3

    # Bytes 20–24 	Basic display parameters
    struct :video_input_parameters do
      bit1 :digital_inputs_switch

      # Digital if above is 1
      bit3 :bit_depth_code, onlyif: :digital_inputs?
      bit4 :video_interface_code, onlyif: :digital_inputs?

      # Analog if above is 0
      bit3 :white_sync_levels_code, onlyif: :analog_inputs?
      bit1 :blank_to_blank_setup_expected_switch, onlyif: :analog_inputs?
      bit1 :separate_sync_supported_switch, onlyif: :analog_inputs?
      bit1 :composite_sync_supported_switch, onlyif: :analog_inputs?
      bit1 :vsync_pulse_required_switch, onlyif: :analog_inputs?
    end

    uint8 :horizontal_screen_size_in_cm
    uint8 :vertical_screen_size_in_cm
    uint8 :display_gamma_raw

    struct :supported_features do
      bit1 :dpms_standby_support_bit
      bit1 :dpms_suspend_support_bit
      bit1 :dpms_active_off_support_bit
      bit2 :display_type_bits
      # bit2 :display_type_analog_bits
      bit1 :standard_srgb_color_space_switch
      bit1 :preferred_timing_mode_specified_in_descriptor_block_1_switch
      bit1 :continuous_timings_with_gtf_or_cvt_switch
    end

    # Bytes 25–34
    struct :chromaticity_coordinates do
      bit2 :red_x_value_least_significant_bits
      bit2 :red_y_value_least_significant_bits
      bit2 :green_x_value_least_significant_bits
      bit2 :green_y_value_least_significant_bits

      bit8 :blue_and_white_least_significant_2_bits
      bit8 :red_x_value_most_significant_8_bits
      bit8 :red_y_value_most_significant_8_bits
      bit8 :green_x_value_most_significant_8_bits
      bit8 :green_y_value_most_significant_8_bits
      bit8 :blue_x_value_most_significant_8_bits
      bit8 :blue_y_value_most_significant_8_bits
      bit8 :default_white_point_x_most_significant_8_bits
      bit8 :default_white_point_y_most_significant_8_bits
    end

    # Bytes 35-37
    # Established timing bitmap
    array :established_timings_list_1, type: :bit1, initial_length: 8
    array :established_timings_list_2, type: :bit1, initial_length: 8
    array :established_timings_list_3, type: :bit1, initial_length: 8

    # Bytes 38-53
    # Standard timing information

    struct :standard_timing do
      uint8 :i1_x_resolution
      bit2  :i1_image_aspect_ration
      bit6  :i1_vertical_frequency

      uint8 :i2_x_resolution
      bit2  :i2_image_aspect_ration
      bit6  :i2_vertical_frequency

      uint8 :i3_x_resolution
      bit2  :i3_image_aspect_ration
      bit6  :i3_vertical_frequency

      uint8 :i4_x_resolution
      bit2  :i4_image_aspect_ration
      bit6  :i4_vertical_frequency

      uint8 :i5_x_resolution
      bit2  :i5_image_aspect_ration
      bit6  :i5_vertical_frequency

      uint8 :i6_x_resolution
      bit2  :i6_image_aspect_ration
      bit6  :i6_vertical_frequency

      uint8 :i7_x_resolution
      bit2  :i7_image_aspect_ration
      bit6  :i7_vertical_frequency

      uint8 :i8_x_resolution
      bit2  :i8_image_aspect_ration
      bit6  :i8_vertical_frequency
    end

    # Byetes 54–71
    # string :descriptor_1, read_length: 18
    struct :descriptor_1 do
      # 0-1
      uint16le :pixel_clock
      # 2
      bit8 :horizontal_active_pixels_8
      # 3
      bit8 :horizontal_blanking_pixels
      # 4
      bit4 :horizontal_active_pixels_4
      bit4 :horizontal_blanking_pixels_4
      # 5
      bit8 :vertical_active_pixels_8
      # 6
      bit8 :vertical_blanking_pixels
      # 7
      bit4 :vertical_active_pixels_4
      bit4 :vertical_blanking_pixels_4
      # 8
      bit8 :horizontal_front_porch
      # 9
      bit8 :horizontal_sync_pulse_width
      # 10
      bit4 :vertical_front_porch
      bit4 :vertical_sync_pulse_width
      # 11
      bit2 :horizontal_front_porch_2
      bit2 :horizontal_sync_pulse_width_2
      bit2 :vertical_front_porch_2
      bit2 :vertical_sync_pulse_width_2
      # 12
      bit8 :horizontal_image_size
      # 13
      bit8 :vertical_image_size
      # 14
      bit4 :horizontal_image_size_4bit
      bit4 :vertical_image_size_4bit
      # 15
      bit8 :horizontal_border_pixels_one_side
      # 16
      bit8 :vertical_border_lines
      # 17
      struct :features do
        bit1 :interlaced
        bit2 :stereo_mode_2
        bit2 :digital_sync
        bit1 :vertical_sync_polarity
        bit1 :reserved
        bit1 :stereo_mode_1
      end

    end
    struct :descriptor_2 do
      # string :descriptor_2, read_length: 18
      uint16be :indicator
      int8 :reserved
      int8 :descriptor_type
      int8 :reserved_for_display_range_limits
      #string :text, read_length: 13, pad_front: true
      string :text, length: 13
    end
    struct :descriptor_3 do
      # string :descriptor_2, read_length: 18
      uint16be :indicator
      int8 :reserved
      int8 :descriptor_type
      int8 :reserved_for_display_range_limits
      #string :text, read_length: 13, pad_front: true
      string :text, length: 13
    end
    struct :descriptor_4 do
      # string :descriptor_2, read_length: 18
      uint16be :indicator
      int8 :reserved
      int8 :descriptor_type
      int8 :reserved_for_display_range_limits
      #string :text, read_length: 13, pad_front: true
      string :text, length: 13
    end
    # string :descriptor_3, read_length: 18
    # struct :descriptor_3 do
    #   # string :descriptor_2, read_length: 18
    #   bit2 :indicator
    #   bit1 :reserved
    #   bit1 :descriptor_type
    #   bit1 :reserved_for_display_range_limits
    #   string :text, read_length: 13
    # end
    # # string :descriptor_4, read_length: 18
    # struct :descriptor_4 do
    #   # string :descriptor_2, read_length: 18
    #   bit2 :indicator
    #   bit1 :reserved
    #   bit1 :descriptor_type
    #   bit1 :reserved_for_display_range_limits
    #   string :text, read_length: 13
    # end
    uint8 :num_extensions_to_follow
    uint8 :checksum

    def analog_display_type
      ANALOG_DISPLAY_TYPES.fetch supported_features[:display_type_bits], 'unknown'
    end

    def bit_depth
      BIT_DEPTHS.fetch video_input_parameters[:bit_depth_code], 'undefined'
    end

    def digital_display_type
      DIGITAL_DISPLAY_TYPES.fetch supported_features[:display_type_bits], 'unknown'
    end

    def display_name
      descriptor_4[:text].strip
    end

    def display_serial_number
      descriptor_2[:text].strip
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
        EDID #{edid_version}.#{edid_revision}

        Digital input? #{digital_inputs?}
        Bit depth: #{bit_depth}
        Video Interface: #{video_interface}
        White and sync levels relative to blank: #{white_sync_levels}

        Horizontal screen size: #{horizontal_screen_size_in_cm} cm
        Vertical screen size: #{vertical_screen_size_in_cm} cm
        Display gamma: #{display_gamma_raw}

        DPMS standby: #{supported_features[:dpms_standby_support_bit] == 1 ? 'yes' : 'no'}
        DPMS suspend: #{supported_features[:dpms_suspend_support_bit] == 1 ? 'yes' : 'no'}
        DPMS active-off: #{supported_features[:dpms_active_off_support_bit] == 1 ? 'yes' : 'no'}
        Display type: #{digital_display_type}
        Analog type: #{analog_display_type}

        Descriptors:
          Display serial number: #{display_serial_number}
          Display name: #{display_name}

        Checksum: #{checksum}
      MESSAGE
    end

    private

    def analog_inputs?
      video_input_parameters[:digital_inputs_switch].zero?
    end

    def digital_inputs?
      video_input_parameters[:digital_inputs_switch].positive?
    end
  end
end

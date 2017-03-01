module CleverTap
  # unit uploading profile data to CleverTap
  class Uploader
    HTTP_PATH = 'upload'.freeze

    TYPE_EVENT = :event
    TYPE_PROFILE = :profile

    ENTITY_DATA_NAMES = {
      TYPE_EVENT => 'evtData',
      TYPE_PROFILE => 'profileData'
    }.freeze

    DEBUG_PARAMS = { dryRun: 1 }.freeze

    attr_reader :records, :type, :identity_field, :date_field, :event_name, :debug

    # TODO: make defaults configurable
    # date_field should be a date object responding to `to_i` which
    # should returns epoch time
    # profile respond to .to_h
    def initialize(records, identity_field: 'id', date_field: nil, event_name: nil, debug: false)
      @type = event_name ? TYPE_EVENT : TYPE_PROFILE
      @records = records

      @identity_field = identity_field
      @date_field = date_field
      @event_name = event_name
      @debug = debug
    end

    def call(client)
      response = client.post(HTTP_PATH, build_request_body) do |request|
        request.params.merge!(DEBUG_PARAMS) if debug
      end

      parse_response(response)
    end

    private

    def build_request_body
      records.each_with_object('d' => []) do |record, request_body|
        request_body['d'] << normalize_record(record)
      end.to_json
    end

    def normalize_record(record)
      ts = date_field ? record[date_field] : Time.now

      {
        'identity' => record[identity_field].to_s,
        'ts' => ts.to_i,
        'type' => type,
        ENTITY_DATA_NAMES[type] => record.to_h
      }.tap do |hash|
        hash.merge!('evtName' => event_name) if type == TYPE_EVENT
      end
    end

    def parse_response(http_response)
      http_response
    end
  end
end

require 'net/http';
require 'uri'
require 'json'
require_relative 'Station'
require_relative 'Endpoint'

QUERY_FROM = '&from='
QUERY_TO   = '&to='

class Search

    def initialize(from_station, to_station)
        @from_station = from_station
        @to_station = to_station
    end

    def getUrl(from_code, to_code)
        search_url = Endpoint.getSearchUrl
        url = search_url + QUERY_FROM + from_code + QUERY_TO + to_code
        return url
    end

    def getUri(url)
        url_escape = URI.escape(url)
        uri = URI(url_escape)
        return uri
    end

    def getStationCode(station_name)
        sta_obj = Station.new(station_name)
        stations = sta_obj.getResponse["ResultSet"]["Point"]

        # 候補が1つのときは配列ではなくhashで返ってくるため
        if (stations.is_a?(Hash))
            first_station = stations
        else
            first_station = stations[0]
        end

        if (first_station.nil?)
            return ''
        end

        return first_station["Station"]["code"]
    end

    def main
        from_station_code = getStationCode(@from_station)
        to_station_code   = getStationCode(@to_station)
        if (from_station_code.empty? || to_station_code.empty?)
            return
        end

        url = getUrl(from_station_code, to_station_code)
        uri = getUri(url)
        body = Net::HTTP.get_response(uri).body;
        json = JSON.parse(body);
        resource_uri = json["ResultSet"]["ResourceURI"]
        if (resource_uri.nil?)
            return
        end
        return resource_uri
    end

end

sta = Search.new("渋谷", "東京")
p sta.main()

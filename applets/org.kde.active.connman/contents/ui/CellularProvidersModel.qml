import Qt 4.7

XmlListModel {
    property string providerName
    property string countryCode
    source: "/usr/share/mobile-broadband-provider-info/serviceproviders.xml"
    query:  "/serviceproviders"

    XmlRole {
        name: "countries"
        query: "@code[1]/string()"
    }

   XmlRole {
        name: "providers"
        query: "country/[@code = '"+ countryCode +"']/provider/name/string()"
    }

    XmlRole {
        name: "apn"
        query: "country[@code = '"+ countryCode +"']/provider[name = '"+providerName+"']/gsm/apn/@value[1]/string()"
    }

    XmlRole {
        name: "username"
        query: "country[@code = '"+ countryCode +"']/provider[name = '"+providerName+"']/gsm/apn/username/string()"
    }

    XmlRole {
        name: "password"
        query: "country[@code = '"+ countryCode +"']/provider[name = '"+providerName+"']/gsm/apn/password/string()"
    }
}

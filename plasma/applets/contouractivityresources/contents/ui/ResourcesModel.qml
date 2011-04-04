/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

QtObject {

    function model(name)
    {
        switch (name) {
        case "Network":
            return networkModel;
            break;
        case "Grandma's birthday":
            return birthdayModel;
            break;
        case "Managing Photos":
            return photosModel;
            break;
        default:
        }
    }

    property ListModel network: ListModel {
        id: networkModel
        ListElement {
            name: "Contacts"
            elements: [
                ListElement {
                    name: "Bill Jones"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Jane Doe"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "John Smith"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "John Smith"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Bill Jones"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Jane Doe"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "John Smith"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "John Smith"
                    icon: "pics/qtlogo.png"
                }
            ]
        }
        ListElement {
            name: "Applications"
            elements: [
                ListElement {
                    name: "konqueror"
                    icon: "konqueror"
                },
                ListElement {
                    name: "kmail"
                    icon: "kmail"
                }
            ]
        }
        ListElement {
            name: "Files"
            elements: [
                ListElement {
                    name: "Book 1"
                    icon: "application-epub"
                },
                ListElement {
                    name: "Receipt.pdf"
                    icon: "application-pdf"
                }
            ]
        }
        ListElement {
            name: "Communication"
            elements: [
                ListElement {
                    name: "Hello, how..."
                    icon: "view-pim-mail"
                }
            ]
        }
        ListElement {
            name: "URLs"
            elements: [
                ListElement {
                    name: "Gmail"
                    icon: "kmail"
                },
                ListElement {
                    name: "Facebook"
                    icon: "facebook"
                },
                ListElement {
                    name: "Kde.org"
                    icon: "start-here-kde"
                }
            ]
        }
    }

    property ListModel birthday: ListModel {
        id: birthdayModel
        ListElement {
            name: "Applications"
            elements: [
                ListElement {
                    name: "KAddressbook"
                    icon: "kaddressbook"
                },
                ListElement {
                    name: "Words"
                    icon: "kword"
                },
                ListElement {
                    name: "KOrganizer"
                    icon: "korganizer"
                },
                ListElement {
                    name: "Kopete"
                    icon: "kopete"
                }
            ]
        }
        ListElement {
            name: "Contacts"
            elements: [
                ListElement {
                    name: "Grandma"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Mom"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Dad"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Mary"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Albert"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Restaurant"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Flower store"
                    icon: "view-pim-contacts"
                }
            ]
        }
        ListElement {
            name: "Locations"
            elements: [
                ListElement {
                    name: "Ristorante Gino"
                    icon: "marble"
                },
                ListElement {
                    name: "Grandma's house"
                    icon: "marble"
                },
                ListElement {
                    name: "Flower store"
                    icon: "marble"
                }
            ]
        }
        ListElement {
            name: "Media"
            elements: [
                ListElement {
                    name: "The Blue Danube"
                    icon: "audio-ac3"
                },
                ListElement {
                    name: "Era de maggio"
                    icon: "audio-ac3"
                },
                ListElement {
                    name: "Brandenburg Concerto 1"
                    icon: "audio-ac3"
                }
            ]
        }
        ListElement {
            name: "Tasks"
            elements: [
                ListElement {
                    name: "Call the restaurant"
                    icon: "view-task"
                },
                ListElement {
                    name: "Invitation"
                    icon: "view-task"
                },
                ListElement {
                    name: "call flower store"
                    icon: "view-task"
                },
                ListElement {
                    name: "buy the present"
                    icon: "view-task"
                }
            ]
        }
        ListElement {
            name: "Urls"
            elements: [
                ListElement {
                    name: "Ristorante Gino"
                    icon: "text-html"
                },
                ListElement {
                    name: "Fisherman's restaurant"
                    icon: "text-html"
                },
                ListElement {
                    name: "Blossom flowers"
                    icon: "text-html"
                },
                ListElement {
                    name: "Flowers express"
                    icon: "text-html"
                },
                ListElement {
                    name: "Goldsmith"
                    icon: "text-html"
                }
            ]
        }
    }


    property ListModel photos: ListModel {
        id: photosModel
        ListElement {
            name: "Applications"
            elements: [
                ListElement {
                    name: "Digikam"
                    icon: "digikam"
                },
                ListElement {
                    name: "Konqueror"
                    icon: "konqueror"
                }
            ]
        }
        ListElement {
            name: "Files"
            elements: [
                ListElement {
                    name: "Last holidays (10)"
                    icon: "image-x-generic"
                },
                ListElement {
                    name: "Akademy (25)"
                    icon: "image-x-generic"
                },
                ListElement {
                    name: "Marco's slides"
                    icon: "application-vnd.oasis.opendocument.presentation"
                }
            ]
        }
        ListElement {
            name: "Locations"
            elements: [
                ListElement {
                    name: "Barcelona"
                    icon: "marble"
                },
                ListElement {
                    name: "Tapas Bar"
                    icon: "marble"
                },
                ListElement {
                    name: "Tampere"
                    icon: "marble"
                }
            ]
        }
        ListElement {
            name: "Urls"
            elements: [
                ListElement {
                    name: "Flickr.com"
                    icon: "text-html"
                }
            ]
        }
        ListElement {
            name: "Events"
            elements: [
                ListElement {
                    name: "Holiday in Barcelona"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "KDE conference"
                    icon: "view-pim-contacts"
                }
            ]
        }
    }
}

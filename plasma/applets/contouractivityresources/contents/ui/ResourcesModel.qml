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
        case "Diploma thesis":
            return thesisModel;
            break;
        default:
        }
    }

    property ListModel network: ListModel {
        id: networkModel
        ListElement {
            name: "Contacts"
            countHint: 0
            elements: [
                ListElement {
                    name: "Bill Jones"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Jane Doe"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "John Smith"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "John Smith"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Bill Jones"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Jane Doe"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "John Smith"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "John Smith"
                    icon: "view-pim-contacts"
                }
            ]
        }
        ListElement {
            name: "Applications"
            countHint: 0
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
            countHint: 0
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
            countHint: 0
            elements: [
                ListElement {
                    name: "Hello, how..."
                    icon: "view-pim-mail"
                }
            ]
        }
        ListElement {
            name: "URLs"
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
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
            countHint: 0
            elements: [
                ListElement {
                    name: "Flickr.com"
                    icon: "text-html"
                }
            ]
        }
        ListElement {
            name: "Events"
            countHint: 0
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

    property ListModel thesis: ListModel {
        id: thesisModel
        ListElement {
            name: "Applications"
            countHint: 0
            elements: [
                ListElement {
                    name: "Task Juggler"
                    icon: "taskbar"
                },
                ListElement {
                    name: "Words"
                    icon: "kword"
                },
                ListElement {
                    name: "Stage"
                    icon: "kpresenter"
                },
                ListElement {
                    name: "ChemSketch"
                    icon: "kalzium"
                }
            ]
        }
        ListElement {
            name: "Media"
            countHint: 1
            elements: [
                ListElement {
                    name: "Playlist_aggressive_1"
                    icon: "audio-ac3"
                },
                ListElement {
                    name: "Playlist_calmdown_4"
                    icon: "audio-ac3"
                }
            ]
        }
        ListElement {
            name: "Locations"
            countHint: 2
            elements: [
                ListElement {
                    name: "University TU Darmstadt"
                    icon: "marble"
                },
                ListElement {
                    name: "Institut for zoology"
                    icon: "marble"
                },
                ListElement {
                    name: "Library"
                    icon: "marble"
                },
                ListElement {
                    name: "Biology Library Frankfurt"
                    icon: "marble"
                },
                ListElement {
                    name: "Starbucks"
                    icon: "marble"
                },
                ListElement {
                    name: "Home office"
                    icon: "marble"
                },
                ListElement {
                    name: "Mates house"
                    icon: "marble"
                }
            ]
        }
        ListElement {
            name: "Events"
            countHint: 0
            elements: [
                ListElement {
                    name: "Meeting with professor"
                    icon: "view-task"
                },
                ListElement {
                    name: "Discussion with collegue"
                    icon: "view-task"
                },
                ListElement {
                    name: "Call mum"
                    icon: "view-task"
                },
                ListElement {
                    name: "Send update Saturday"
                    icon: "view-task"
                },
                ListElement {
                    name: "Expedition to Brazil"
                    icon: "view-task"
                }
            ]
        }
        ListElement {
            name: "Urls"
            countHint: 0
            elements: [
                ListElement {
                    name: "Wikipedia - Oopaga..."
                    icon: "text-html"
                },
                ListElement {
                    name: "www.tropical-rainforest.animals.com"
                    icon: "text-html"
                },
                ListElement {
                    name: "www.bgsu.edu"
                    icon: "text-html"
                },
                ListElement {
                    name: "www.natgeo education video.com"
                    icon: "text-html"
                },
                ListElement {
                    name: "Frogs mailinglist"
                    icon: "text-html"
                }
            ]
        }
        ListElement {
            name: "Contacts"
            countHint: 0
            elements: [
                ListElement {
                    name: "Kiki Summers"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Horst Töpfert"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Mum"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Cindy"
                    icon: "view-pim-contacts"
                },
                ListElement {
                    name: "Librarian"
                    icon: "view-pim-contacts"
                }
            ]
        }
        ListElement {
            name: "Files"
            countHint: 0
            elements: [
                ListElement {
                    name: "MyThesys_V1.odp"
                    icon: "application-vnd.oasis.opendocument.presentation"
                },
                ListElement {
                    name: "PoisonDartFrog.pdf"
                    icon: "application-pdf"
                },
                ListElement {
                    name: "Oopaga pumillium call.ogg"
                    icon: "audio-ac3"
                },
                ListElement {
                    name: "MyThesys_V2.odp"
                    icon: "application-vnd.oasis.opendocument.presentation"
                },
                ListElement {
                    name: "MyThesys_V3.odp"
                    icon: "application-vnd.oasis.opendocument.presentation"
                },
                ListElement {
                    name: "Oopaga pumillium zoo.jpg"
                    icon: "image-x-generic"
                }
            ]
        }
    }
}

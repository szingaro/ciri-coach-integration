/*****************************************************************************
 *  Copyright (C) 2021 by Stefano P. Zingaro <stefanopio.zingaro@unibo.it>   *
 *                                                                           *
 *  This program is free software; you can redistribute it and/or modify     *
 *  it under the terms of the GNU Library General Public License as          *
 *  published by the Free Software Foundation; either version 2 of the       *
 *  License, or (at your option) any later version.                          *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *
 *  GNU General Public License for more details.                             *
 *                                                                           *
 *  You should have received a copy of the GNU Library General Public        *
 *  License along with this program; if not, write to the                    *
 *  Free Software Foundation, Inc.,                                          *
 *  59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                *
 *                                                                           *
 *  For details about the authors of this software, see the README file.    *
 *****************************************************************************/

from file import File
from time import Time

constants {
    AUTH_TOKEN = "tdbdeimeu5hw7ei6mo3ugg5e0hvegxlqzvbmreiye5eedqq6xh47hgmxurch7iic",
    PUSH_EVERY = 30000
}

service RomagnaTechConnector
{
    outputPort RomagnaTech {
        location: "socket://romagnatech.resiot.net:443/"
        protocol: https {
            debug = true
            compression = false
            format = "json"
            addHeader.header << "Authorization" { value = AUTH_TOKEN }   
            osc.notify << { alias = "endpoints/636f6e38" method = "post" }
        }
        OneWay: notify
    }

	embed File as File
    embed Time as Time
	
	main
	{
        readFile@File( {
            filename = "data/items.json"
            format = "json"
        } )( items )

        for( item in items._ ) {
            notify@RomagnaTech( item )
            sleep@Time( PUSH_EVERY )()
        }
    }
}
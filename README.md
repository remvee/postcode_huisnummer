# PostcodeHuisnummer

Een webapplicatie welke de Nederlandse "Basisregistratie Adressen en Gebouwen" gegevens gebruikt om adresinformatie op basis van postcode huisnummer op te kunnen zoeken.  De data wordt automatisch van [NLExtract](http://www.nlextract.nl/) gedownload en up-to-date gehouden.


## Performance

Buiten de omvang van de dataset (meer dan 8,8 miljoen adressen op moment van schrijven) is deze applicatie snel in het leveren van resultaten dankzij een PostgreSQL database met indexen.  Het automatische updaten van de dataset gebeurt op de achtergrond en heeft vrijwel geen impact op de performance van de postcode-huisnummer-bevragingen.  Deze applicatie draait, bijvoorbeeld, prima op een Raspberry Pi 3 waar het updaten van de dataset 5 en een half uur in beslag neemt.


## Gebruik

De applicatie is ontwikkeld met behulp van [Elixir](http://elixir-lang.org/), [Phoenix](http://phoenixframework.org/) en PostgreSQL (https://www.postgresql.org/).  Op een debian-achtige omgeving zie het opstarten ervan ongeveer als volgt uit:

  * Installeer Elixir, PostgreSQL en Node.js met `apt-get install elixir erlang-nox erlang-dev postgres nodejs`
  * Installeer de afhankelijkheden met `mix deps.get`
  * Maak de database aan met `mix ecto.create && mix ecto.migrate`
  * Installeer de Node.js afhankelijkheden met `npm install`
  * Start webapplicatie met `mix phoenix.server`

Nu kan [`localhost:4000`](http://localhost:4000) bezocht worden in de webbrowser en, als de adresgegevens allemaal ingeladen zijn, adressen opgevraagd worden met postcode en huisnummer.  De dataset wordt meteen geladen maar kan enkele tijd (uren) nemen voor deze gereed is.


## Copyright

Copyright (C) 2107 R.W. van 't Veer

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a [copy](COPYING) of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

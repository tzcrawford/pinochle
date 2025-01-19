#!/bin/bash
# Credit to the following repository, distributed under GPL-3.
# https://github.com/derwyddon/postgreql_countries.sql/tree/master


CONFIG_FILE="config.json"
# Check if config.json exists; if not, create from template
if [ ! -e "$CONFIG_FILE" ]; then
    echo "Could not find $CONFIG_FILE, creating from template"
    cp config.json.template "$CONFIG_FILE" || exit 1
fi
# Read configuration from config.json
APP_NAME=$(jq -r '.siteTitle' "$CONFIG_FILE")
DB_NAME=$(jq -r '.postgresDBName' "$CONFIG_FILE")
DB_PORT=$(jq -r '.postgresPort' "$CONFIG_FILE")
DB_USER=$(jq -r '.postgresUsername' "$CONFIG_FILE")
DB_LOCALE=$(jq -r '.postgresLocale' "$CONFIG_FILE" || echo "C.UTF-8")
DB_ENCODING=$(jq -r '.postgresEncoding' "$CONFIG_FILE" || echo "UTF8")
DB_LOCATION=$(jq -r '.postgresDBLocation' "$CONFIG_FILE")
PGHOST="/run/user/$(id -u)/pinochle-postgresql"

heredoc_content=$(cat << SQL
START TRANSACTION;
SET standard_conforming_strings=off;
SET escape_string_warning=off;
SET CONSTRAINTS ALL DEFERRED;

DROP TABLE IF EXISTS "continents" CASCADE;
CREATE TABLE "continents" (
    "code" char(2) NOT NULL,
    "name" varchar(510) DEFAULT NULL,
    PRIMARY KEY ("code")
);
COMMENT on column continents.code is 'Continent code';
COMMENT on column continents.name is 'Continent name';
DROP TABLE IF EXISTS "countries" CASCADE;
CREATE TABLE "countries" (
    "code" char(2) NOT NULL,
    "name" varchar(128) NOT NULL,
    "full_name" varchar(256),
    "iso3" char(3),
    "iso_number" int2 ,
    "continent" char(2) NOT NULL,
    PRIMARY KEY ("code")
);
COMMENT on column countries.code is 'Two-letter countries code (ISO 3166-1 alpha-2)';
COMMENT on column countries.name is 'English country name';
COMMENT on column countries.full_name is 'Full English country name';
COMMENT on column countries.iso3 is 'Three-letter country code (ISO 3166-1 alpha-3)';
COMMENT on column countries.iso_number is 'Three-letter country code (ISO 3166-1 numeric)';

--
-- Data for Name: continents; Type: TABLE DATA
--

INSERT INTO continents
    (code, name)
VALUES
 ('AF', 'Africa')
,('AN', 'Antarctica')
,('AS', 'Asia')
,('EU', 'Europe')
,('NA', 'North America')
,('OC', 'Oceania')
,('SA', 'South America');

--
-- Data for Name: countries; Type: TABLE DATA
--

INSERT INTO countries
    (code, name, full_name, iso3, iso_number, continent)
VALUES
 ('AD', 'Andorra', 'Principality of Andorra', 'AND', 20, 'EU')
,('AE', 'United Arab Emirates', 'United Arab Emirates', 'ARE', 784, 'AS')
,('AF', 'Afghanistan', 'Islamic Republic of Afghanistan', 'AFG', 4, 'AS')
,('AG', 'Antigua and Barbuda', 'Antigua and Barbuda', 'ATG', 28, 'NA')
,('AI', 'Anguilla', 'Anguilla', 'AIA', 660, 'NA')
,('AL', 'Albania', 'Republic of Albania', 'ALB', 8, 'EU')
,('AM', 'Armenia', 'Republic of Armenia', 'ARM', 51, 'AS')
,('AN', 'Netherlands Antilles', 'Netherlands Antilles', 'ANT', 530, 'NA')
,('AO', 'Angola', 'Republic of Angola', 'AGO', 24, 'AF')
,('AQ', 'Antarctica', 'Antarctica (the territory South of 60 deg S)', 'ATA', 10, 'AN')
,('AR', 'Argentina', 'Argentine Republic', 'ARG', 32, 'SA')
,('AS', 'American Samoa', 'American Samoa', 'ASM', 16, 'OC')
,('AT', 'Austria', 'Republic of Austria', 'AUT', 40, 'EU')
,('AU', 'Australia', 'Commonwealth of Australia', 'AUS', 36, 'OC')
,('AW', 'Aruba', 'Aruba', 'ABW', 533, 'NA')
,('AX', 'Åland', 'Åland Islands', 'ALA', 248, 'EU')
,('AZ', 'Azerbaijan', 'Republic of Azerbaijan', 'AZE', 31, 'AS')
,('BA', 'Bosnia and Herzegovina', 'Bosnia and Herzegovina', 'BIH', 70, 'EU')
,('BB', 'Barbados', 'Barbados', 'BRB', 52, 'NA')
,('BD', 'Bangladesh', 'People''s Republic of Bangladesh', 'BGD', 50, 'AS')
,('BE', 'Belgium', 'Kingdom of Belgium', 'BEL', 56, 'EU')
,('BF', 'Burkina Faso', 'Burkina Faso', 'BFA', 854, 'AF')
,('BG', 'Bulgaria', 'Republic of Bulgaria', 'BGR', 100, 'EU')
,('BH', 'Bahrain', 'Kingdom of Bahrain', 'BHR', 48, 'AS')
,('BI', 'Burundi', 'Republic of Burundi', 'BDI', 108, 'AF')
,('BJ', 'Benin', 'Republic of Benin', 'BEN', 204, 'AF')
,('BL', 'Saint Barthélemy', 'Saint Barthelemy', 'BLM', 652, 'NA')
,('BM', 'Bermuda', 'Bermuda', 'BMU', 60, 'NA')
,('BN', 'Brunei Darussalam', 'Brunei Darussalam', 'BRN', 96, 'AS')
,('BO', 'Bolivia', 'Republic of Bolivia', 'BOL', 68, 'SA')
,('BR', 'Brazil', 'Federative Republic of Brazil', 'BRA', 76, 'SA')
,('BS', 'Bahamas', 'Commonwealth of the Bahamas', 'BHS', 44, 'NA')
,('BT', 'Bhutan', 'Kingdom of Bhutan', 'BTN', 64, 'AS')
,('BV', 'Bouvet Island', 'Bouvet Island (Bouvetoya)', 'BVT', 74, 'AN')
,('BW', 'Botswana', 'Republic of Botswana', 'BWA', 72, 'AF')
,('BY', 'Belarus', 'Republic of Belarus', 'BLR', 112, 'EU')
,('BZ', 'Belize', 'Belize', 'BLZ', 84, 'NA')
,('CA', 'Canada', 'Canada', 'CAN', 124, 'NA')
,('CC', 'Cocos (Keeling) Islands', 'Cocos (Keeling) Islands', 'CCK', 166, 'AS')
,('CD', 'Congo (Kinshasa)', 'Democratic Republic of the Congo', 'COD', 180, 'AF')
,('CF', 'Central African Republic', 'Central African Republic', 'CAF', 140, 'AF')
,('CG', 'Congo (Brazzaville)', 'Republic of the Congo', 'COG', 178, 'AF')
,('CH', 'Switzerland', 'Swiss Confederation', 'CHE', 756, 'EU')
,('CI', 'Côte d''Ivoire', 'Republic of Cote d''Ivoire', 'CIV', 384, 'AF')
,('CK', 'Cook Islands', 'Cook Islands', 'COK', 184, 'OC')
,('CL', 'Chile', 'Republic of Chile', 'CHL', 152, 'SA')
,('CM', 'Cameroon', 'Republic of Cameroon', 'CMR', 120, 'AF')
,('CN', 'China', 'People''s Republic of China', 'CHN', 156, 'AS')
,('CO', 'Colombia', 'Republic of Colombia', 'COL', 170, 'SA')
,('CR', 'Costa Rica', 'Republic of Costa Rica', 'CRI', 188, 'NA')
,('CU', 'Cuba', 'Republic of Cuba', 'CUB', 192, 'NA')
,('CV', 'Cape Verde', 'Republic of Cape Verde', 'CPV', 132, 'AF')
,('CX', 'Christmas Island', 'Christmas Island', 'CXR', 162, 'AS')
,('CY', 'Cyprus', 'Republic of Cyprus', 'CYP', 196, 'AS')
,('CZ', 'Czech Republic', 'Czech Republic', 'CZE', 203, 'EU')
,('DE', 'Germany', 'Federal Republic of Germany', 'DEU', 276, 'EU')
,('DJ', 'Djibouti', 'Republic of Djibouti', 'DJI', 262, 'AF')
,('DK', 'Denmark', 'Kingdom of Denmark', 'DNK', 208, 'EU')
,('DM', 'Dominica', 'Commonwealth of Dominica', 'DMA', 212, 'NA')
,('DO', 'Dominican Republic', 'Dominican Republic', 'DOM', 214, 'NA')
,('DZ', 'Algeria', 'People''s Democratic Republic of Algeria', 'DZA', 12, 'AF')
,('EC', 'Ecuador', 'Republic of Ecuador', 'ECU', 218, 'SA')
,('EE', 'Estonia', 'Republic of Estonia', 'EST', 233, 'EU')
,('EG', 'Egypt', 'Arab Republic of Egypt', 'EGY', 818, 'AF')
,('EH', 'Western Sahara', 'Western Sahara', 'ESH', 732, 'AF')
,('ER', 'Eritrea', 'State of Eritrea', 'ERI', 232, 'AF')
,('ES', 'Spain', 'Kingdom of Spain', 'ESP', 724, 'EU')
,('ET', 'Ethiopia', 'Federal Democratic Republic of Ethiopia', 'ETH', 231, 'AF')
,('FI', 'Finland', 'Republic of Finland', 'FIN', 246, 'EU')
,('FJ', 'Fiji', 'Republic of the Fiji Islands', 'FJI', 242, 'OC')
,('FK', 'Falkland Islands', 'Falkland Islands (Malvinas)', 'FLK', 238, 'SA')
,('FM', 'Micronesia', 'Federated States of Micronesia', 'FSM', 583, 'OC')
,('FO', 'Faroe Islands', 'Faroe Islands', 'FRO', 234, 'EU')
,('FR', 'France', 'French Republic', 'FRA', 250, 'EU')
,('GA', 'Gabon', 'Gabonese Republic', 'GAB', 266, 'AF')
,('GB', 'United Kingdom', 'United Kingdom of Great Britain & Northern Ireland', 'GBR', 826, 'EU')
,('GD', 'Grenada', 'Grenada', 'GRD', 308, 'NA')
,('GE', 'Georgia', 'Georgia', 'GEO', 268, 'AS')
,('GF', 'French Guiana', 'French Guiana', 'GUF', 254, 'SA')
,('GG', 'Guernsey', 'Bailiwick of Guernsey', 'GGY', 831, 'EU')
,('GH', 'Ghana', 'Republic of Ghana', 'GHA', 288, 'AF')
,('GI', 'Gibraltar', 'Gibraltar', 'GIB', 292, 'EU')
,('GL', 'Greenland', 'Greenland', 'GRL', 304, 'NA')
,('GM', 'Gambia', 'Republic of the Gambia', 'GMB', 270, 'AF')
,('GN', 'Guinea', 'Republic of Guinea', 'GIN', 324, 'AF')
,('GP', 'Guadeloupe', 'Guadeloupe', 'GLP', 312, 'NA')
,('GQ', 'Equatorial Guinea', 'Republic of Equatorial Guinea', 'GNQ', 226, 'AF')
,('GR', 'Greece', 'Hellenic Republic Greece', 'GRC', 300, 'EU')
,('GS', 'South Georgia and South Sandwich Islands', 'South Georgia and the South Sandwich Islands', 'SGS', 239, 'AN')
,('GT', 'Guatemala', 'Republic of Guatemala', 'GTM', 320, 'NA')
,('GU', 'Guam', 'Guam', 'GUM', 316, 'OC')
,('GW', 'Guinea-Bissau', 'Republic of Guinea-Bissau', 'GNB', 624, 'AF')
,('GY', 'Guyana', 'Co-operative Republic of Guyana', 'GUY', 328, 'SA')
,('HK', 'Hong Kong', 'Hong Kong Special Administrative Region of China', 'HKG', 344, 'AS')
,('HM', 'Heard and McDonald Islands', 'Heard Island and McDonald Islands', 'HMD', 334, 'AN')
,('HN', 'Honduras', 'Republic of Honduras', 'HND', 340, 'NA')
,('HR', 'Croatia', 'Republic of Croatia', 'HRV', 191, 'EU')
,('HT', 'Haiti', 'Republic of Haiti', 'HTI', 332, 'NA')
,('HU', 'Hungary', 'Republic of Hungary', 'HUN', 348, 'EU')
,('ID', 'Indonesia', 'Republic of Indonesia', 'IDN', 360, 'AS')
,('IE', 'Ireland', 'Ireland', 'IRL', 372, 'EU')
,('IL', 'Israel', 'State of Israel', 'ISR', 376, 'AS')
,('IM', 'Isle of Man', 'Isle of Man', 'IMN', 833, 'EU')
,('IN', 'India', 'Republic of India', 'IND', 356, 'AS')
,('IO', 'British Indian Ocean Territory', 'British Indian Ocean Territory (Chagos Archipelago)', 'IOT', 86, 'AS')
,('IQ', 'Iraq', 'Republic of Iraq', 'IRQ', 368, 'AS')
,('IR', 'Iran', 'Islamic Republic of Iran', 'IRN', 364, 'AS')
,('IS', 'Iceland', 'Republic of Iceland', 'ISL', 352, 'EU')
,('IT', 'Italy', 'Italian Republic', 'ITA', 380, 'EU')
,('JE', 'Jersey', 'Bailiwick of Jersey', 'JEY', 832, 'EU')
,('JM', 'Jamaica', 'Jamaica', 'JAM', 388, 'NA')
,('JO', 'Jordan', 'Hashemite Kingdom of Jordan', 'JOR', 400, 'AS')
,('JP', 'Japan', 'Japan', 'JPN', 392, 'AS')
,('KE', 'Kenya', 'Republic of Kenya', 'KEN', 404, 'AF')
,('KG', 'Kyrgyzstan', 'Kyrgyz Republic', 'KGZ', 417, 'AS')
,('KH', 'Cambodia', 'Kingdom of Cambodia', 'KHM', 116, 'AS')
,('KI', 'Kiribati', 'Republic of Kiribati', 'KIR', 296, 'OC')
,('KM', 'Comoros', 'Union of the Comoros', 'COM', 174, 'AF')
,('KN', 'Saint Kitts and Nevis', 'Federation of Saint Kitts and Nevis', 'KNA', 659, 'NA')
,('KP', 'Korea, North', 'Democratic People''s Republic of Korea', 'PRK', 408, 'AS')
,('KR', 'Korea, South', 'Republic of Korea', 'KOR', 410, 'AS')
,('KW', 'Kuwait', 'State of Kuwait', 'KWT', 414, 'AS')
,('KY', 'Cayman Islands', 'Cayman Islands', 'CYM', 136, 'NA')
,('KZ', 'Kazakhstan', 'Republic of Kazakhstan', 'KAZ', 398, 'AS')
,('LA', 'Laos', 'Lao People''s Democratic Republic', 'LAO', 418, 'AS')
,('LB', 'Lebanon', 'Lebanese Republic', 'LBN', 422, 'AS')
,('LC', 'Saint Lucia', 'Saint Lucia', 'LCA', 662, 'NA')
,('LI', 'Liechtenstein', 'Principality of Liechtenstein', 'LIE', 438, 'EU')
,('LK', 'Sri Lanka', 'Democratic Socialist Republic of Sri Lanka', 'LKA', 144, 'AS')
,('LR', 'Liberia', 'Republic of Liberia', 'LBR', 430, 'AF')
,('LS', 'Lesotho', 'Kingdom of Lesotho', 'LSO', 426, 'AF')
,('LT', 'Lithuania', 'Republic of Lithuania', 'LTU', 440, 'EU')
,('LU', 'Luxembourg', 'Grand Duchy of Luxembourg', 'LUX', 442, 'EU')
,('LV', 'Latvia', 'Republic of Latvia', 'LVA', 428, 'EU')
,('LY', 'Libya', 'Libyan Arab Jamahiriya', 'LBY', 434, 'AF')
,('MA', 'Morocco', 'Kingdom of Morocco', 'MAR', 504, 'AF')
,('MC', 'Monaco', 'Principality of Monaco', 'MCO', 492, 'EU')
,('MD', 'Moldova', 'Republic of Moldova', 'MDA', 498, 'EU')
,('ME', 'Montenegro', 'Republic of Montenegro', 'MNE', 499, 'EU')
,('MF', 'Saint Martin (French part)', 'Saint Martin', 'MAF', 663, 'NA')
,('MG', 'Madagascar', 'Republic of Madagascar', 'MDG', 450, 'AF')
,('MH', 'Marshall Islands', 'Republic of the Marshall Islands', 'MHL', 584, 'OC')
,('MK', 'Macedonia', 'Republic of Macedonia', 'MKD', 807, 'EU')
,('ML', 'Mali', 'Republic of Mali', 'MLI', 466, 'AF')
,('MM', 'Myanmar', 'Union of Myanmar', 'MMR', 104, 'AS')
,('MN', 'Mongolia', 'Mongolia', 'MNG', 496, 'AS')
,('MO', 'Macau', 'Macao Special Administrative Region of China', 'MAC', 446, 'AS')
,('MP', 'Northern Mariana Islands', 'Commonwealth of the Northern Mariana Islands', 'MNP', 580, 'OC')
,('MQ', 'Martinique', 'Martinique', 'MTQ', 474, 'NA')
,('MR', 'Mauritania', 'Islamic Republic of Mauritania', 'MRT', 478, 'AF')
,('MS', 'Montserrat', 'Montserrat', 'MSR', 500, 'NA')
,('MT', 'Malta', 'Republic of Malta', 'MLT', 470, 'EU')
,('MU', 'Mauritius', 'Republic of Mauritius', 'MUS', 480, 'AF')
,('MV', 'Maldives', 'Republic of Maldives', 'MDV', 462, 'AS')
,('MW', 'Malawi', 'Republic of Malawi', 'MWI', 454, 'AF')
,('MX', 'Mexico', 'United Mexican States', 'MEX', 484, 'NA')
,('MY', 'Malaysia', 'Malaysia', 'MYS', 458, 'AS')
,('MZ', 'Mozambique', 'Republic of Mozambique', 'MOZ', 508, 'AF')
,('NA', 'Namibia', 'Republic of Namibia', 'NAM', 516, 'AF')
,('NC', 'New Caledonia', 'New Caledonia', 'NCL', 540, 'OC')
,('NE', 'Niger', 'Republic of Niger', 'NER', 562, 'AF')
,('NF', 'Norfolk Island', 'Norfolk Island', 'NFK', 574, 'OC')
,('NG', 'Nigeria', 'Federal Republic of Nigeria', 'NGA', 566, 'AF')
,('NI', 'Nicaragua', 'Republic of Nicaragua', 'NIC', 558, 'NA')
,('NL', 'Netherlands', 'Kingdom of the Netherlands', 'NLD', 528, 'EU')
,('NO', 'Norway', 'Kingdom of Norway', 'NOR', 578, 'EU')
,('NP', 'Nepal', 'State of Nepal', 'NPL', 524, 'AS')
,('NR', 'Nauru', 'Republic of Nauru', 'NRU', 520, 'OC')
,('NU', 'Niue', 'Niue', 'NIU', 570, 'OC')
,('NZ', 'New Zealand', 'New Zealand', 'NZL', 554, 'OC')
,('OM', 'Oman', 'Sultanate of Oman', 'OMN', 512, 'AS')
,('PA', 'Panama', 'Republic of Panama', 'PAN', 591, 'NA')
,('PE', 'Peru', 'Republic of Peru', 'PER', 604, 'SA')
,('PF', 'French Polynesia', 'French Polynesia', 'PYF', 258, 'OC')
,('PG', 'Papua New Guinea', 'Independent State of Papua New Guinea', 'PNG', 598, 'OC')
,('PH', 'Philippines', 'Republic of the Philippines', 'PHL', 608, 'AS')
,('PK', 'Pakistan', 'Islamic Republic of Pakistan', 'PAK', 586, 'AS')
,('PL', 'Poland', 'Republic of Poland', 'POL', 616, 'EU')
,('PM', 'Saint Pierre and Miquelon', 'Saint Pierre and Miquelon', 'SPM', 666, 'NA')
,('PN', 'Pitcairn', 'Pitcairn Islands', 'PCN', 612, 'OC')
,('PR', 'Puerto Rico', 'Commonwealth of Puerto Rico', 'PRI', 630, 'NA')
,('PS', 'Palestine', 'Occupied Palestinian Territory', 'PSE', 275, 'AS')
,('PT', 'Portugal', 'Portuguese Republic', 'PRT', 620, 'EU')
,('PW', 'Palau', 'Republic of Palau', 'PLW', 585, 'OC')
,('PY', 'Paraguay', 'Republic of Paraguay', 'PRY', 600, 'SA')
,('QA', 'Qatar', 'State of Qatar', 'QAT', 634, 'AS')
,('RE', 'Reunion', 'Reunion', 'REU', 638, 'AF')
,('RO', 'Romania', 'Romania', 'ROU', 642, 'EU')
,('RS', 'Serbia', 'Republic of Serbia', 'SRB', 688, 'EU')
,('RU', 'Russian Federation', 'Russian Federation', 'RUS', 643, 'EU')
,('RW', 'Rwanda', 'Republic of Rwanda', 'RWA', 646, 'AF')
,('SA', 'Saudi Arabia', 'Kingdom of Saudi Arabia', 'SAU', 682, 'AS')
,('SB', 'Solomon Islands', 'Solomon Islands', 'SLB', 90, 'OC')
,('SC', 'Seychelles', 'Republic of Seychelles', 'SYC', 690, 'AF')
,('SD', 'Sudan', 'Republic of Sudan', 'SDN', 736, 'AF')
,('SE', 'Sweden', 'Kingdom of Sweden', 'SWE', 752, 'EU')
,('SG', 'Singapore', 'Republic of Singapore', 'SGP', 702, 'AS')
,('SH', 'Saint Helena', 'Saint Helena', 'SHN', 654, 'AF')
,('SI', 'Slovenia', 'Republic of Slovenia', 'SVN', 705, 'EU')
,('SJ', 'Svalbard and Jan Mayen Islands', 'Svalbard & Jan Mayen Islands', 'SJM', 744, 'EU')
,('SK', 'Slovakia', 'Slovakia (Slovak Republic)', 'SVK', 703, 'EU')
,('SL', 'Sierra Leone', 'Republic of Sierra Leone', 'SLE', 694, 'AF')
,('SM', 'San Marino', 'Republic of San Marino', 'SMR', 674, 'EU')
,('SN', 'Senegal', 'Republic of Senegal', 'SEN', 686, 'AF')
,('SO', 'Somalia', 'Somali Republic', 'SOM', 706, 'AF')
,('SR', 'Suriname', 'Republic of Suriname', 'SUR', 740, 'SA')
,('ST', 'Sao Tome and Principe', 'Democratic Republic of Sao Tome and Principe', 'STP', 678, 'AF')
,('SV', 'El Salvador', 'Republic of El Salvador', 'SLV', 222, 'NA')
,('SY', 'Syria', 'Syrian Arab Republic', 'SYR', 760, 'AS')
,('SZ', 'Swaziland', 'Kingdom of Swaziland', 'SWZ', 748, 'AF')
,('TC', 'Turks and Caicos Islands', 'Turks and Caicos Islands', 'TCA', 796, 'NA')
,('TD', 'Chad', 'Republic of Chad', 'TCD', 148, 'AF')
,('TF', 'French Southern Lands', 'French Southern Territories', 'ATF', 260, 'AN')
,('TG', 'Togo', 'Togolese Republic', 'TGO', 768, 'AF')
,('TH', 'Thailand', 'Kingdom of Thailand', 'THA', 764, 'AS')
,('TJ', 'Tajikistan', 'Republic of Tajikistan', 'TJK', 762, 'AS')
,('TK', 'Tokelau', 'Tokelau', 'TKL', 772, 'OC')
,('TL', 'Timor-Leste', 'Democratic Republic of Timor-Leste', 'TLS', 626, 'AS')
,('TM', 'Turkmenistan', 'Turkmenistan', 'TKM', 795, 'AS')
,('TN', 'Tunisia', 'Tunisian Republic', 'TUN', 788, 'AF')
,('TO', 'Tonga', 'Kingdom of Tonga', 'TON', 776, 'OC')
,('TR', 'Turkey', 'Republic of Turkey', 'TUR', 792, 'AS')
,('TT', 'Trinidad and Tobago', 'Republic of Trinidad and Tobago', 'TTO', 780, 'NA')
,('TV', 'Tuvalu', 'Tuvalu', 'TUV', 798, 'OC')
,('TW', 'Taiwan', 'Taiwan', 'TWN', 158, 'AS')
,('TZ', 'Tanzania', 'United Republic of Tanzania', 'TZA', 834, 'AF')
,('UA', 'Ukraine', 'Ukraine', 'UKR', 804, 'EU')
,('UG', 'Uganda', 'Republic of Uganda', 'UGA', 800, 'AF')
,('UM', 'United States Minor Outlying Islands', 'United States Minor Outlying Islands', 'UMI', 581, 'OC')
,('US', 'United States of America', 'United States of America', 'USA', 840, 'NA')
,('UY', 'Uruguay', 'Eastern Republic of Uruguay', 'URY', 858, 'SA')
,('UZ', 'Uzbekistan', 'Republic of Uzbekistan', 'UZB', 860, 'AS')
,('VA', 'Vatican City', 'Holy See (Vatican City State)', 'VAT', 336, 'EU')
,('VC', 'Saint Vincent and the Grenadines', 'Saint Vincent and the Grenadines', 'VCT', 670, 'NA')
,('VE', 'Venezuela', 'Bolivarian Republic of Venezuela', 'VEN', 862, 'SA')
,('VG', 'Virgin Islands, British', 'British Virgin Islands', 'VGB', 92, 'NA')
,('VI', 'Virgin Islands, U.S.', 'United States Virgin Islands', 'VIR', 850, 'NA')
,('VN', 'Vietnam', 'Socialist Republic of Vietnam', 'VNM', 704, 'AS')
,('VU', 'Vanuatu', 'Republic of Vanuatu', 'VUT', 548, 'OC')
,('WF', 'Wallis and Futuna Islands', 'Wallis and Futuna', 'WLF', 876, 'OC')
,('WS', 'Samoa', 'Independent State of Samoa', 'WSM', 882, 'OC')
,('YE', 'Yemen', 'Yemen', 'YEM', 887, 'AS')
,('YT', 'Mayotte', 'Mayotte', 'MYT', 175, 'AF')
,('ZA', 'South Africa', 'Republic of South Africa', 'ZAF', 710, 'AF')
,('ZM', 'Zambia', 'Republic of Zambia', 'ZMB', 894, 'AF')
,('ZW', 'Zimbabwe', 'Republic of Zimbabwe', 'ZWE', 716, 'AF')
,('BQ', 'Bonaire', 'Bonaire, Sint Eustatius and Saba', 'BES', 535, 'NA')
,('CW', 'Curaçao', 'Curaçao', 'CUW', 531, 'NA')
,('SS', 'South Sudan', 'South Sudan', 'SSD', 728, 'AF')
,('SX', 'Sint Maarten', 'Sint Maarten (Dutch part)', 'SXM', 534, 'NA')
,('XK', 'Kosovo', 'Kosovo', '',0, 'EU');

--
-- PostgreSQL database dump complete
--


COMMIT;
START TRANSACTION;

-- Typecasts --

-- Foreign keys --
ALTER TABLE "countries" ADD CONSTRAINT "country_ibfk_1" FOREIGN KEY ("continent") REFERENCES "continents" ("code") ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX ON "countries" ("continent");


COMMIT;
--
-- PostgreSQL database dump complete
--
SQL
)

source ./${DB_USER}_password && psql -d postgres -h "$PGHOST" -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "$heredoc_content"


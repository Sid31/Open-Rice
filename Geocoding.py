import googlemaps
from datetime import datetime

gmaps = googlemaps.Client(key='AIzaSyDKzKaeO1Y_mE-C1bdo_UlehtwlKI5oQic')

def glookup(names):
	geocode_result = []
	coordinates = []
	for i in range(len(names)):
		geocode_result.append(gmaps.geocode(names[i]))
		location = geocode_result[i][0]['geometry']['location'] if bool(geocode_result[i]) else None
		print i
		coordinates.append([location['lat'], location['lng']]) if location is not None else coordinates.append([0,0])
	return coordinates

def fixOpenRiceCoords(names, lats, longs):
	if (len(lats) != len(longs) & len(lats) != len(names)):
		return 'Latitudes and Longitudes do not match'
	bad_names=[]
	for i in range(len(lats)):
		try:
			float(lats[i]) & float(longs[i])
		except ValueError:
			bad_names.append(names[i])
		else:
			if (lats[i] < 22 or lats[i] > 23):
				bad_names.append(names[i])
			else if (longs[i] > 115):
				print bad_names.append(names[i])

		return bad_names

bad=[]
for i in range(9500):
	try:
		float(Locations[i][0])
	except ValueError:
		bad.append(i)
	else:
		if (float(Locations[i][0])<114 or float(Locations[i][0])>115):
			bad.append(i)
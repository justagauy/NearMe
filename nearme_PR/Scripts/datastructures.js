//// "class" Feature
//function Feature(locationId, 
//                locationTypeEnumCode,
//                locationGroupEnumCode,
//                name,
//                city,
//                custom,
//                latitude,
//                longitude) {

//    this.LocationId = locationId;
//    this.LocationTypeEnumCode = locationTypeEnumCode;
//    this.LocationGroupEnumCode = locationGroupEnumCode;
//    this.Name = name;
//    this.City = city;
//    this.Custom = custom;
//    this.Latitude = latitude;
//    this.Longitude = longitude;
//}

// "class" Feature
function Location(id,
                name,
                description,
                telephone,
                lat,
                lon,
                type) {

    this.Id = id;
    this.Name = name;
    this.Description = description;
    this.Telephone = telephone;
    this.Latitude = lat;
    this.Longitude = lon;
    this.Type = type;
}

// -----------------------------------------------------------

// "class" FeatureFieldWithCount
function FeatureFieldWithCount(name, count) {
    this.Name = name;
    this.Count = count;
}

// -----------------------------------------------------------

// "class" FeatureList
function FeatureList() {
    this.items = new Array();
}

FeatureList.prototype.AddItem = function (item) {
    this.items[this.items.length] = item;
};

FeatureList.prototype.GetItem = function (index) {
    return this.items[index];
};

FeatureList.prototype.GetItemCount = function () {
    return this.items.length;
};

FeatureList.prototype.Clear = function () {
    this.items.length = 0;
};
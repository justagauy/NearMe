<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="nearme_PR.Test" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>#NearMePR</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <script src="http://code.jquery.com/jquery-1.6.4.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false"></script>
    <script type="text/javascript" src="Scripts/datastructures.js"></script>

    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Ionicons -->
    <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="css/AdminLTE.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
          <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->

    <style>
        .simpleModal
        {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            margin-top: -9em;
            margin-left: -15em;
            border: 1px solid #ccc;
            z-index: 9999;
            background-color: White;
            text-align: center;
            border-style: solid;
            border-width: 2px;
            border-color: Green;
        }

        .modalBlanket
        {
            background: none repeat scroll 0 0 #000000;
            bottom: 0;
            display: block;
            height: 100%;
            left: 0;
            margin: 0;
            opacity: 0.15;
            padding: 0;
            position: fixed;
            right: 0;
            top: 0;
            width: 100%;
            z-index: 101;
            display: none;
        }

    </style>

    <script type="text/javascript">

        function ShowHideDivModal(divId, modalBlanketClassName) {
            var modalBlanket = $("." + modalBlanketClassName);
            var div = $("#" + divId);
            var toShow = div.css("display") == "none" ? true : false;

            if (toShow) {
                modalBlanket.fadeIn('slow');
                div.fadeIn('slow');
            }
            else {
                modalBlanket.fadeOut('slow');
                div.fadeOut('slow');
            }
        }

        // Google Maps init ************************************************
        var m_map = null;
        var m_cityCircle = null;
        var m_myLocMarker = null;
        var m_markers = null;
        var m_CircleRadius = 1;
        
        var lstLocations = new FeatureList();

        // "Enum" of layers to avoid hard coding
        var m_MapStatus = {
            Unknown: -1,
            AddingBuffer: 0,
            AddingLocation: 1
        };

        var m_CurrentMapStatus = m_MapStatus.AddingBuffer;

        // "Enum" of categories to avoid hard coding
        var m_Categories = {
            Salud: "Salud",
            Educacion: "Educacion",
            Seguridad: "Seguridad",
            Entretenimiento: "Entretenimiento"
        };

        // "Enum" of layers to avoid hard coding
        var m_Layers = {
            CDT: "CDT",
            Escuela: "Escuela",
            WIFI: "WIFI",
            AcopioReciclaje: "Acopio y Reciclaje"
        };

        // associative array containing the layers of each category(joins m_Categories & m_Layers).
        var m_CategoryLayers = InitializeLayerToCategoryAssociation();

        function initialize() {
            var mapOptions = {
                zoom: 9,
                center: new google.maps.LatLng(18.3, -66.3),
                mapTypeId: google.maps.MapTypeId.SATELLITE
            };

            m_map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

            MapReady();
        }

        google.maps.event.addDomListener(window, 'load', initialize);
        // End Google Maps init ************************************************

        // Function Executes as soon as the map is ready.
        function MapReady() {
            SetDefaultValues();

            SetMapStatus(m_MapStatus.AddingBuffer);

            //// map onclick event handler.
            //google.maps.event.addListener(m_map, "click", function (e) {
            //    CreateCircleBuffer(e.latLng.lat(), e.latLng.lng(), m_CircleRadius, m_map, false);
            //});

            //GetCurrentPositionCircle(m_CircleRadius);
        }

        function CallAddPointServ() {
            inputArray = [];
            inputArray[0] = $("#txtNombre").val();
            inputArray[1] = $("#txtDescripcion").val();
            inputArray[2] = $("#ddlCategoria").val();
            inputArray[3] = m_myLocMarker.position.lat();
            inputArray[4] = m_myLocMarker.position.lng();

            var jsonParams = "{ fields: " + JSON.stringify(inputArray) + "}";

            $.ajax({
                url: "Test.aspx/AddLocation",
                data: jsonParams,
                dataType: "json",
                async: false,
                type: "POST",
                contentType: "application/json; charset=utf-8",
                success: completedCallback,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    // it returns "error" if a ' is inputted.    
                    // we dont wanna show an innecesary err. msg.                         
                    if (textStatus != "error")
                        alert(textStatus);
                }
            });

            function completedCallback(data) {
                if (data && data.d != null && data.d != "") {
                    alert(data.d);
                }
                else {
                    alert("Punto añadido.");
                }

                SetMapStatus(m_MapStatus.AddingBuffer);

                ShowHideDivModal('AddLocationModal', 'modalBlanket');                
            }
        }

        function GetLocationsByType(locationTypes) {
            var inputArray = [];

            var TypesCount = locationTypes.length;

            ClearAllFeatures(false);

            for (var i = 0; i < TypesCount; i++) {
                inputArray[0] = locationTypes[i];

                var jsonParams = "{ fields: " + JSON.stringify(inputArray) + "}";

                $.ajax({
                    url: "Test.aspx/GetLocationsByType",
                    data: jsonParams,
                    dataType: "json",
                    async: false,
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    success: completedCallback,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        // it returns "error" if a ' is inputted.    
                        // we dont wanna show an innecesary err. msg.                         
                        if (textStatus != "error")
                            alert(textStatus);
                    }
                });
            }

            // always refresh counters as soon as we get the points.
            GetCounters();

            function completedCallback(data) {
                if (data && data != null && data != undefined) {

                    $.each(data.d, function (key, value) {
                        var id = value.Id;
                        var name = value.Name;
                        var description = value.Description;
                        var telephone = value.Telephone;
                        var latitude = value.Latitude;
                        var longitude = value.Longitude;
                        var type = value.Type;

                        var point = new google.maps.LatLng(parseFloat(latitude), parseFloat(longitude));

                        var marker = new google.maps.Marker({ position: point, title: name, map: m_map });

                        m_markers.push(marker);

                        // populate the list that will contain the reference of the features.
                        var ft = new Location(id, name, description, telephone, latitude, longitude, type);
                        lstLocations.AddItem(ft);
                    });
                    
                }
            }
        }

        function GetCurrentPositionCircle(onCompleteCallBack) {
            navigator.geolocation.getCurrentPosition(GotCurrentPosition);

            function GotCurrentPosition(myLocation) {
                CreateCircleBuffer(myLocation.coords.latitude, myLocation.coords.longitude, m_CircleRadius, m_map, false);
                onCompleteCallBack();
            }
        }

        function CreateMarker(lat, lon, map, markerName) {
            var myLatlng = new google.maps.LatLng(lat, lon);
            
            m_myLocMarker = new google.maps.Marker({
                position: myLatlng,
                map: map,
                title: markerName
            });

            m_markers.push(m_myLocMarker);
        }

        function CreateCircleBuffer(lat, lon, radiusMiles, map, createMarker) {
            var myLatlng = new google.maps.LatLng(lat, lon);

            if (createMarker) {
                CreateMarker(lat, lon, map, "Localidad Seleccionada");
                //m_myLocMarker = new google.maps.Marker({
                //    position: myLatlng,
                //    map: map,
                //    title: 'Selected Location'
                //});
            }

            var circleOptions = {
                strokeColor: '#FF0000',
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillColor: '#FF0000',
                fillOpacity: 0.35,
                map: map,
                center: myLatlng,
                radius: radiusMiles * 1609.344
            };

            ClearAllFeatures(true);

            m_cityCircle = new google.maps.Circle(circleOptions);
        }

        function ClearAllFeatures(clearAllShapes) {

            // remove any existing circle.
            if (clearAllShapes && m_cityCircle && m_cityCircle != null) {
                m_cityCircle.setMap(null);
            }

            if (lstLocations)
                lstLocations.Clear();

            if (m_markers && m_markers.length !== 0) {
                for (var i = 0; i < m_markers.length; ++i) {
                    m_markers[i].setMap(null);
                }

                m_markers = null;
            }

            m_markers = [];
        }

        function GetCounters() {
            var cntSalud = 0;
            var cntEdu = 0;
            var cntSegu = 0;
            var cntEntr = 0;

            for (var i = 0; i < lstLocations.GetItemCount(); i++) {
                var value = lstLocations.GetItem(i);
                var layerCategory = GetLayerCategory(value.Type);

                if (layerCategory == m_Categories.Salud) {
                    cntSalud += 1;
                }
                else if (layerCategory == m_Categories.Educacion) {
                    cntEdu += 1;
                }
                else if (layerCategory == m_Categories.Entretenimiento) {
                    cntEntr += 1;
                }
                else if (layerCategory == m_Categories.Seguridad) {
                    cntSegu += 1;
                }
            }
            
            document.getElementById('divSalud').innerHTML = cntSalud * document.getElementById('sldSalud').value;
            document.getElementById('divEducacion').innerHTML = cntEdu * document.getElementById('sldEdc').value;
            document.getElementById('divSeguridad').innerHTML = cntSegu * document.getElementById('sldSeg').value;
            document.getElementById('divEntretenimiento').innerHTML = cntEntr * document.getElementById('sldEnt').value;
        }

        // Remove those features not inside the already existing circle.       
        function FilterMarkersByCircle() {
            if (m_markers && m_cityCircle && m_cityCircle != null) {

                var indicesThatWillStay = [];

                $.each(m_markers, function (index, value) {
                    if (!m_cityCircle.contains(value.position)) {
                        value.setMap(null);
                    }
                    else {
                        indicesThatWillStay.push(index);
                    }
                });

                DeleteIndicesFromMyParallelList(indicesThatWillStay);
            }

            function DeleteIndicesFromMyParallelList(indicesThatWillStay) {
                var newList = new FeatureList();
                for (var i = 0; i < lstLocations.GetItemCount() ; i++) {
                    if (indicesThatWillStay.indexOf(i) >= 0) {
                        newList.AddItem(lstLocations[i]);
                    }
                }
                lstLocations = newList;
            }
        }

        // evaluates if the recieved latlon is contained in the circle.
        google.maps.Circle.prototype.contains = function (latLng) {
            var ret = false;

            try{
                ret = this.getBounds().contains(latLng) && google.maps.geometry.spherical.computeDistanceBetween(this.getCenter(), latLng) <= this.getRadius();
            }
            catch (e) {
                ret = false;
            }

            return ret;
        }

        function GetNearPlaces() {
            var types = GetDesiredFeatureTypesArray();
            GetLocationsByType(types);
            FilterMarkersByCircle();
        }
        
        // get users selected feature type layers by category.
        // if Educacion category was selected, all layers in that
        // category are added.
        function GetDesiredFeatureTypesArray() {

            //var types = ['CDT', 'WIFI', 'Escuela', 'acopio y Reciclaje'];
            var selTypes = [];

            if ($("#cbSalud").is(':checked')) {
                PushLayersByCategory(m_Categories.Salud, selTypes);
            }
            if ($("#cbEducacion").is(':checked')) {
                PushLayersByCategory(m_Categories.Educacion, selTypes);
            }
            if ($("#cbSeguridad").is(':checked')) {
                PushLayersByCategory(m_Categories.Seguridad, selTypes);
            }
            if ($("#cbEntretenimiento").is(':checked')) {
                PushLayersByCategory(m_Categories.Entretenimiento, selTypes);
            }

            return selTypes;
        }

        /* Category/Layers management(refactor into separate .js file) START */

        // will associate the different types of layers(cdt, escuela, wifi, etc), 
        // into categories(Salud, Educacion, Seguridad, Entretenimiento).
        // var arrLayers = ['CDT', 'WIFI', 'Escuela', 'Acopio y Reciclaje'];
        //categories[m_Categories.Salud] = [m_Layers.CDT, m_Layers.AcopioReciclaje]; // example
        function InitializeLayerToCategoryAssociation() {            
            var categories = {};

            categories[m_Categories.Salud] = [m_Layers.CDT];
            categories[m_Categories.Educacion] = [m_Layers.Escuela];
            categories[m_Categories.Seguridad] = [m_Layers.AcopioReciclaje];
            categories[m_Categories.Entretenimiento] = [m_Layers.WIFI];

            return categories;
        }

        // category == layer type text (m_Categories)
        // arrLayers == byref array that we will push the layers
        //              of the received category
        function PushLayersByCategory(category, arrLayers) {
            if (m_CategoryLayers && m_CategoryLayers[category] && arrLayers) {
                for (var i = 0; i < m_CategoryLayers[category].length; i++) {
                    arrLayers.push(m_CategoryLayers[category][i]);
                }
            }
        }

        // returns the category of a layer.
        function GetLayerCategory(layerName) {
            var layerCategory = null;

            // iterate through the arrays contained in keys.
            $.each(m_CategoryLayers, function (key, value) {

                var found = false;
                
                $.each(m_CategoryLayers[key], function (i, innerValue) {
                    if (innerValue == layerName) {
                        layerCategory = key;
                        found = true;
                        return false;
                    }
                });

                if (found == true)
                    return false;
            });

            return layerCategory;
        }

        /* END */

        // function called from onchange event of the circle slider.
        function RefreshCircleRadius(val) {
            m_CircleRadius = val;
        }

        function SetDefaultValues() {
            document.getElementById('sldMiles').value = m_CircleRadius;
        }

        function AddLocation() {
            
        }
        
        function SetMapStatus(mapStatus) {

            google.maps.event.clearListeners(m_map, 'click');

            m_CurrentMapStatus = mapStatus;

            $("#txtNombre").val("");
            $("#txtDescripcion").val("");
            
            if (mapStatus == m_MapStatus.AddingBuffer) {

                // map onclick event handler.
                google.maps.event.addListener(m_map, "click", function (e) {                    
                    CreateCircleBuffer(e.latLng.lat(), e.latLng.lng(), m_CircleRadius, m_map, false);
                });

                $("#btnAddLocation").prop('value', 'Añadir Localidad');

                ClearAllFeatures(true);
            }
            else {

                // map onclick event handler.
                google.maps.event.addListener(m_map, "click", function (e) {
                    CreateMarker(e.latLng.lat(), e.latLng.lng(), m_map, "Localidad por Añadir");
                    ShowHideDivModal('AddLocationModal', 'modalBlanket');
                });
                
                $("#btnAddLocation").prop('value', 'Seleccione un Punto');
            }

        }

    </script>
</head>
<body class="skin-blue">
    <!-- header logo: style can be found in header.less -->
    <header class="header">
        <a href="Default.aspx" class="logo">#NearMePR
            </a>
        <!-- Header Navbar: style can be found in header.less -->
        <nav class="navbar navbar-static-top" role="navigation">
            <!-- Sidebar toggle button-->
            <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </a>
            <div class="navbar-right">

                <ul class="nav navbar-nav">
                    <!-- Messages: style can be found in dropdown.less-->
                    <li class="dropdown messages-menu">

                        <%--
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-envelope"></i>
                            <span class="label label-success">4</span>
                        </a>

                        <ul class="dropdown-menu">
                            <li class="header">You have 4 messages</li>
                            <li>
                                <!-- inner menu: contains the actual data -->
                                <ul class="menu">
                                    <li>
                                        <!-- start message -->
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/avatar3.png" class="img-circle" alt="User Image" />
                                            </div>
                                            <h4>Support Team
                                                   
                                                <small><i class="fa fa-clock-o"></i>5 mins</small>
                                            </h4>
                                        </a>
                                    </li>
                                    <!-- end message -->
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/avatar2.png" class="img-circle" alt="user image" />
                                            </div>
                                            <h4>Truenorth
                                                   
                                                <small><i class="fa fa-clock-o"></i>2 hours</small>
                                            </h4>

                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/avatar.png" class="img-circle" alt="user image" />
                                            </div>
                                            <h4>Developers
                                                   
                                                <small><i class="fa fa-clock-o"></i>Today</small>
                                            </h4>

                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/avatar2.png" class="img-circle" alt="user image" />
                                            </div>
                                            <h4>Sales Department
                                                   
                                                <small><i class="fa fa-clock-o"></i>Yesterday</small>
                                            </h4>

                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <div class="pull-left">
                                                <img src="img/avatar.png" class="img-circle" alt="user image" />
                                            </div>
                                            <h4>Reviewers
                                                   
                                                <small><i class="fa fa-clock-o"></i>2 days</small>
                                            </h4>

                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="footer"><a href="#">See All Messages</a></li>
                        </ul>--%>


                    </li>
                    <!-- Notifications: style can be found in dropdown.less -->
                    <li class="dropdown notifications-menu">
                        <%--<a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-warning"></i>
                            <span class="label label-warning">10</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li class="header">You have 10 notifications</li>
                            <li>
                                <!-- inner menu: contains the actual data -->
                                <ul class="menu">
                                    <li>
                                        <a href="#">
                                            <i class="ion ion-ios7-people info"></i>5 new members joined today
                                            </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="fa fa-warning danger"></i>Very long description here that may not fit into the page and may cause design problems
                                            </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="fa fa-users warning"></i>5 new members joined
                                            </a>
                                    </li>

                                    <li>
                                        <a href="#">
                                            <i class="ion ion-ios7-cart success"></i>25 sales made
                                            </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="ion ion-ios7-person danger"></i>You changed your username
                                            </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="footer"><a href="#">View all</a></li>
                        </ul>--%>
                    </li>
                    <!-- Tasks: style can be found in dropdown.less -->
                    <li class="dropdown tasks-menu">
                        <%--<a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-tasks"></i>
                            <span class="label label-danger">9</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li class="header">You have 9 tasks</li>
                            <li>
                                <!-- inner menu: contains the actual data -->
                                <ul class="menu">
                                    <li>
                                        <!-- Task item -->
                                        <a href="#">
                                            <h3>Design some buttons
                                                   
                                                <small class="pull-right">20%</small>
                                            </h3>
                                            <div class="progress xs">
                                                <div class="progress-bar progress-bar-aqua" style="width: 20%" role="progressbar" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
                                                    <span class="sr-only">20% Complete</span>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <!-- end task item -->
                                    <li>
                                        <!-- Task item -->
                                        <a href="#">
                                            <h3>Create a nice theme
                                                   
                                                <small class="pull-right">40%</small>
                                            </h3>
                                            <div class="progress xs">
                                                <div class="progress-bar progress-bar-green" style="width: 40%" role="progressbar" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
                                                    <span class="sr-only">40% Complete</span>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <!-- end task item -->
                                    <li>
                                        <!-- Task item -->
                                        <a href="#">
                                            <h3>Some task I need to do
                                                   
                                                <small class="pull-right">60%</small>
                                            </h3>
                                            <div class="progress xs">
                                                <div class="progress-bar progress-bar-red" style="width: 60%" role="progressbar" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
                                                    <span class="sr-only">60% Complete</span>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <!-- end task item -->
                                    <li>
                                        <!-- Task item -->
                                        <a href="#">
                                            <h3>Make beautiful transitions
                                                   
                                                <small class="pull-right">80%</small>
                                            </h3>
                                            <div class="progress xs">
                                                <div class="progress-bar progress-bar-yellow" style="width: 80%" role="progressbar" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
                                                    <span class="sr-only">80% Complete</span>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <!-- end task item -->
                                </ul>
                            </li>
                            <li class="footer">
                                <a href="#">View all tasks</a>
                            </li>
                        </ul>--%>
                    </li>
                    <!-- User Account: style can be found in dropdown.less -->
                    <li class="dropdown user user-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="glyphicon glyphicon-user"></i>
                            <span>Usuario <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu">
                            <!-- User image -->
                            <li class="user-header bg-light-blue">
                                <img src="img/avatar3.png" class="img-circle" alt="User Image" />
                                <p>
                                    Mr. Techsummit
                                       
                                    <small>Miembro desde Junio 4, 2014</small>
                                </p>
                            </li>
                            <!-- Menu Body -->
                            <div style="width:100%; text-align:center; font-weight:bold; margin-bottom:5px;">Panel de Control</div>  
                            
                            <div style="width:100%; text-align:center;">
                                <a href="#" style="color:#0073b7;">Localidades</a>
                                &nbsp;&nbsp;&nbsp;
                                <a href="#" style="color:#0073b7;">Configuración</a>
                            </div>  
                                                     
                            <%--<li class="user-body">
                                <div class="col-xs-4 text-center">
                                    <a href="#">Localidades</a>
                                </div>
                                <div class="col-xs-4 text-center">
                                    <a href="#">Config</a>
                                </div>
                                <div class="col-xs-4 text-center">
                                    <a href="#"></a>
                                </div>
                            </li>--%>
                            <!-- Menu Footer-->
                            <li class="user-footer">
                                <div class="pull-left">
                                    <a href="#" class="btn btn-default btn-flat">Perfil</a>
                                </div>
                                <div class="pull-right">
                                    <a href="#" class="btn btn-default btn-flat">Salir</a>
                                </div>
                            </li>
                        </ul>
                    </li>
                </ul>

            </div>
        </nav>
    </header>
    <form id="form1" runat="server">

        <!-- Black screen behind modal. -->
        <div class="modalBlanket">
        </div>

        <div id="AddLocationModal" class="simpleModal">
            <table style=" margin-bottom:20px; margin-left:20px; margin-right:20px; margin-top:10px;">
                <tr>
                    <td colspan="2" style="text-align:center;">
                        <h3>Añadir Localidad</h3>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblNombre" runat="server" >Nombre: </asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtNombre" runat="server" ClientIDMode="Static"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblDescripcion" runat="server" >Descripción: </asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDescripcion" runat="server" ClientIDMode="Static"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblTipo" runat="server" >Tipo: </asp:Label>
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlCategoria" runat="server" Width="152" ClientIDMode="Static">
                            <asp:ListItem Value="-1" Text="Seleccione" Selected="True"  />
                            <asp:ListItem Value="CDT" Text="Salud"   />
                            <asp:ListItem Value="Escuela" Text="Educación"  />
                            <asp:ListItem Value="WIFI" Text="Entretenimiento"  />
                            <asp:ListItem Value="Acopio y Reciclaje" Text="Seguridad"  />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">&nbsp;</td>
                </tr>
                <tr>
                    <td colspan="2" style="text-align:center;" >
                        <asp:Button ID="btnSave" runat="server" Text="Guardar" OnClientClick="CallAddPointServ(); return false;" /> &nbsp;
                        <asp:Button ID="btnCancel" runat="server" Text="Cancelar" OnClientClick="ShowHideDivModal('AddLocationModal', 'modalBlanket'); SetMapStatus(m_MapStatus.AddingBuffer); return false;" />
                    </td>
                </tr>
            </table>
        </div>

        <div class="wrapper row-offcanvas row-offcanvas-left">
            <!-- Left side column. contains the logo and sidebar -->
            <aside class="left-side sidebar-offcanvas">
                <!-- sidebar: style can be found in sidebar.less -->
                <section class="sidebar">
                   
                    <!-- /.search form -->
                    <!-- sidebar menu: : style can be found in sidebar.less -->
                    <%--                    <ul class="sidebar-menu">
                        <li class="active">
                            <a href="Default.aspx">
                                <i class="fa fa-dashboard"></i><span>Location</span>
                            </a>
                        </li>
                    </ul>--%>
                    <div style="padding: 10px; background: white; width: 90%; margin-left: 10px; margin-top: 8px; box-shadow: 0px 1px 4px rgba(0,0,0,0.2)">
                        <div style="border-bottom: 1px solid #d8d8d8;">
                            <h5>
                                <label for="sldMiles">Cobertura(millas):</label></h5>
                        </div>
                        <br />
                        0.5
                            <asp:TextBox ID="sldMiles" type="range" step="0.5" min="0.5" max="5" runat="server" onchange="RefreshCircleRadius(this.value)"></asp:TextBox>
                        5
                        <br />
                        <br />
                        <div style="border-bottom: 1px solid #d8d8d8;">
                            <label>Categorías y Pesos:</label>
                        </div>
                        <br />
                         <h5>
                             <asp:CheckBox ID="cbSalud" runat="server" ClientIDMode="Static" />
                             <asp:Label runat="server" ID="lblType" Text='Salud'></asp:Label>
                         </h5>
                                1
                                    <asp:TextBox ID="sldSalud" type="range" step="1" Value="5" min="1" max="10" runat="server"></asp:TextBox>
                                10
                                    <br />
                        <h5>
                            <asp:CheckBox ID="cbEducacion" runat="server" ClientIDMode="Static" />
                            <asp:Label runat="server" ID="Label1" Text='Educación'></asp:Label>
                        </h5>
                                1
                                    <asp:TextBox ID="sldEdc" type="range" step="1" Value="5" min="1" max="10" runat="server"></asp:TextBox>
                                10
                                    <br />
                        <h5>
                            <asp:CheckBox ID="cbSeguridad" runat="server" ClientIDMode="Static" />
                            <asp:Label runat="server" ID="Label2" Text='Seguridad'></asp:Label>
                        </h5>
                                1
                                    <asp:TextBox ID="sldSeg" type="range" step="1" Value="5" min="1" max="10" runat="server"></asp:TextBox>
                                10
                                    <br />
                        <h5>
                            <asp:CheckBox ID="cbEntretenimiento" runat="server" ClientIDMode="Static" />
                            <asp:Label runat="server" ID="Label3" Text='Entretenimiento'></asp:Label>
                        </h5>
                                1
                                    <asp:TextBox ID="sldEnt" type="range" step="1" Value="5" min="1" max="10" runat="server"></asp:TextBox>
                                10
                                    <br />

                    </div>
                    <div style="padding: 10px; width: 90%; margin-left: 10px; margin-top: 8px;">
                        <asp:Button class="btn btn-block btn-primary" ID="btnFind" runat="server" Width="100%" Text="Buscar" OnClientClick="GetNearPlaces(); return false;" />
                    </div>
                    <div style=" padding-top:5px; padding-bottom:10px;  padding-left:10px; padding-right:10px; width: 90%; margin-left: 10px; margin-top: 2px;">
                        <asp:Button class="btn btn-block btn-primary" ID="btnWhatsNearMe" runat="server" Width="100%" Text="Buscar en mi Posición" OnClientClick="GetCurrentPositionCircle(GetNearPlaces); return false;" />
                    </div>
                    <div style=" padding-top:5px; padding-bottom:10px;  padding-left:10px; padding-right:10px; width: 90%; margin-left: 10px; margin-top: 2px;">
                        <asp:Button class="btn btn-block btn-primary" ID="btnAddLocation" runat="server" Width="100%" Text="Añadir Localidad" OnClientClick="SetMapStatus(m_MapStatus.AddingLocation); return false;" ClientIDMode="Static" />
                        <%--ShowHideDivModal('AddLocationModal', 'modalBlanket'); return false;--%>
                    </div>
                </section>
                <!-- /.sidebar -->
            </aside>

            <!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>Categorías y Puntuaciones
                       
                        <small></small>
                    </h1>
        <%--            <ol class="breadcrumb">
                        <li><a href="#"><i class="fa fa-dashboard"></i>Home</a></li>
                        <li class="active">Near My Location</li>
                    </ol>--%>
                </section>

                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-aqua">
                                <div class="inner">
                                    <h3 id="divSalud">0
                                    </h3>
                                    <p>
                                        
                                        &nbsp;
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-bag"></i>
                                </div>
                               <a href="#" class="small-box-footer">Salud
                                </a>
                            </div>
                        </div>

                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-purple">
                                <div class="inner">
                                    <h3 id="divEducacion">0
                                    </h3>
                                    <p>
                                        
                                        &nbsp;
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-ios7-briefcase-outline"></i>
                                </div>
                                <a href="#" class="small-box-footer">Educación
                                </a>
                            </div>
                        </div>
                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-yellow">
                                <div class="inner">
                                    <h3 id="divSeguridad">0
                                    </h3>
                                    <p>
                                        
                                        &nbsp;
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-person-add"></i>
                                </div>
                                <a href="#" class="small-box-footer">Seguridad
                                </a>
                            </div>
                        </div>

                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-red">
                                <div class="inner">
                                    <h3 id="divEntretenimiento">0
                                    </h3>
                                    <p>
                                        &nbsp;
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-pie-graph"></i>
                                </div>
                               <a href="#" class="small-box-footer">Entretenimiento
                                </a>
                            </div>
                        </div>

                    </div>
                    <div id="divMap" style="padding: 5px; background: white; box-shadow: 0px 1px 4px rgba(0,0,0,0.2); margin-bottom: 6px;">
                        <%--<div>
                            <h4>Map Results</h4>
                        </div>--%>
                        <div id="map-canvas" style="width: 100%; height: 400px;" align="center"></div>
                    </div>
                </section>
                <!-- /.content -->
            </aside>
            <!-- /.right-side -->
        </div>
        <!-- ./wrapper -->

        <!-- add new calendar event modal -->


        <!-- jQuery 2.0.2 -->
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
        <!-- jQuery UI 1.10.3 -->
        <script src="js/jquery-ui-1.10.3.min.js" type="text/javascript"></script>
        <!-- Bootstrap -->
        <script src="js/bootstrap.min.js" type="text/javascript"></script>
        <!-- Morris.js charts -->
        <script src="//cdnjs.cloudflare.com/ajax/libs/raphael/2.1.0/raphael-min.js"></script>
        <script src="js/plugins/morris/morris.min.js" type="text/javascript"></script>
        <!-- Sparkline -->
        <script src="js/plugins/sparkline/jquery.sparkline.min.js" type="text/javascript"></script>
        <!-- jvectormap -->
        <script src="js/plugins/jvectormap/jquery-jvectormap-1.2.2.min.js" type="text/javascript"></script>
        <script src="js/plugins/jvectormap/jquery-jvectormap-world-mill-en.js" type="text/javascript"></script>
        <!-- fullCalendar -->
        <script src="js/plugins/fullcalendar/fullcalendar.min.js" type="text/javascript"></script>
        <!-- jQuery Knob Chart -->
        <script src="js/plugins/jqueryKnob/jquery.knob.js" type="text/javascript"></script>
        <!-- daterangepicker -->
        <script src="js/plugins/daterangepicker/daterangepicker.js" type="text/javascript"></script>
        <!-- Bootstrap WYSIHTML5 -->
        <script src="js/plugins/bootstrap-wysihtml5/bootstrap3-wysihtml5.all.min.js" type="text/javascript"></script>
        <!-- iCheck -->
        <script src="js/plugins/iCheck/icheck.min.js" type="text/javascript"></script>

        <!-- AdminLTE App -->
        <script src="js/AdminLTE/app.js" type="text/javascript"></script>

        <!-- AdminLTE dashboard demo (This is only for demo purposes) -->
        <script src="js/AdminLTE/dashboard.js" type="text/javascript"></script>

        <!-- AdminLTE for demo purposes -->
        <script src="js/AdminLTE/demo.js" type="text/javascript"></script>

    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="nearme_PR.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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


    <script type="text/javascript">

        // vars init
        var m_markers;

        var lstLocations = new FeatureList();

        // Google Maps init ************************************************
        var m_map;

        var m_cityCircle;

        var m_myLocMarker;

        function initialize() {
            var mapOptions = {
                zoom: 9,
                center: new google.maps.LatLng(18.3, -66.3),
                mapTypeId: google.maps.MapTypeId.SATELLITE
            };

            m_map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

            //google.maps.event.addListener(m_map, 'idle', MapReady);

            MapReady();
        }

        google.maps.event.addDomListener(window, 'load', initialize);
        // End Google Maps init ************************************************

        function MapReady() {
            //            alert("MapReady");
            //$(document).ready(function () {
            //    //alert("001");
            //    GetLocationsByType("CDT");
            //});
        }

        function GetLocationsByType(locationType) {
            var inputArray = [];
            inputArray[0] = locationType;

            var jsonParams = "{ fields: " + JSON.stringify(inputArray) + "}";

            $.ajax({
                url: "Default.aspx/GetLocationsByType",
                data: jsonParams,
                dataType: "json",
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
                if (data && data != null && data != undefined) {

                    ClearAllFeatures();

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

        function GetCurrentPositionCircle(miles) {
            navigator.geolocation.getCurrentPosition(GotCurrentPosition);

            function GotCurrentPosition(myLocation) {
                var myLatlng = new google.maps.LatLng(myLocation.coords.latitude, myLocation.coords.longitude);

                m_myLocMarker = new google.maps.Marker({
                    position: myLatlng,
                    map: m_map,
                    title: 'My Location!'
                });

                var circleOptions = {
                    strokeColor: '#FF0000',
                    strokeOpacity: 0.8,
                    strokeWeight: 2,
                    fillColor: '#FF0000',
                    fillOpacity: 0.35,
                    map: m_map,
                    center: myLatlng,
                    radius: miles * 1609.344
                };

                m_cityCircle = new google.maps.Circle(circleOptions);

            }

        }

        function ClearAllFeatures() {

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

    </script>
</head>
<body class="skin-blue">
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
                        </ul>
                    </li>
                    <!-- Notifications: style can be found in dropdown.less -->
                    <li class="dropdown notifications-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
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
                        </ul>
                    </li>
                    <!-- Tasks: style can be found in dropdown.less -->
                    <li class="dropdown tasks-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
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
                        </ul>
                    </li>
                    <!-- User Account: style can be found in dropdown.less -->
                    <li class="dropdown user user-menu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="glyphicon glyphicon-user"></i>
                            <span>User <i class="caret"></i></span>
                        </a>
                        <ul class="dropdown-menu">
                            <!-- User image -->
                            <li class="user-header bg-light-blue">
                                <img src="img/avatar3.png" class="img-circle" alt="User Image" />
                                <p>
                                    User - Web Developer
                                       
                                    <small>Member since May. 2012</small>
                                </p>
                            </li>
                            <!-- Menu Body -->
                            <li class="user-body">
                                <div class="col-xs-4 text-center">
                                    <a href="#">Followers</a>
                                </div>
                                <div class="col-xs-4 text-center">
                                    <a href="#">Sales</a>
                                </div>
                                <div class="col-xs-4 text-center">
                                    <a href="#">Friends</a>
                                </div>
                            </li>
                            <!-- Menu Footer-->
                            <li class="user-footer">
                                <div class="pull-left">
                                    <a href="#" class="btn btn-default btn-flat">Profile</a>
                                </div>
                                <div class="pull-right">
                                    <a href="#" class="btn btn-default btn-flat">Sign out</a>
                                </div>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </header>
    <form id="form1" runat="server">
        <div class="wrapper row-offcanvas row-offcanvas-left">
            <!-- Left side column. contains the logo and sidebar -->
            <aside class="left-side sidebar-offcanvas">
                <!-- sidebar: style can be found in sidebar.less -->
                <section class="sidebar">
                    <!-- Sidebar user panel -->
                    <div class="user-panel">
                        <div class="pull-left image">
                            <img src="img/avatar3.png" class="img-circle" alt="User Image" />
                        </div>
                        <div class="pull-left info">
                            <p>Hello, User</p>

                            <a href="#"><i class="fa fa-circle text-success"></i>Online</a>
                        </div>
                    </div>
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
                                <label for="sldMiles">Miles:</label></h5>
                        </div>
                        <br />
                        0.5
                            <asp:TextBox ID="sldMiles" type="range" step="0.5" min="0.5" max="5" runat="server"></asp:TextBox>
                        5
                            <br />
                        <br />
                        <div style="border-bottom: 1px solid #d8d8d8;">
                            <label>Type:</label>

                        </div>
                        <br />
                        <asp:Repeater ID="rptType" runat="server">
                            <ItemTemplate>
                                <h5>
                                    <asp:Label runat="server" ID="lblType" Text='<%#Container.DataItem%>'></asp:Label></h5>
                                1
                                    <asp:TextBox ID="sldType" type="range" step="1" Value="5" min="1" max="10" runat="server"></asp:TextBox>
                                10
                                    <br />
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </section>
                <!-- /.sidebar -->
            </aside>

            <!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>Near My Location
                       
                    <small></small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="#"><i class="fa fa-dashboard"></i>Home</a></li>
                        <li class="active">Near My Location</li>
                    </ol>
                </section>
                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-aqua">
                                <div class="inner">
                                    <h3>150
                                    </h3>
                                    <p>
                                        CDT
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-bag"></i>
                                </div>
                                <a href="#" class="small-box-footer"><i class="fa fa-arrow-circle-right"></i>
                                </a>
                            </div>
                        </div>

                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-aqua">
                                <div class="inner">
                                    <h3>150
                                    </h3>
                                    <p>
                                        Escuelas
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-bag"></i>
                                </div>
                                <a href="#" class="small-box-footer"> <i class="fa fa-arrow-circle-right"></i>
                                </a>
                            </div>
                        </div>
                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-aqua">
                                <div class="inner">
                                    <h3>150
                                    </h3>
                                    <p>
                                        WIFI
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-bag"></i>
                                </div>
                                <a href="#" class="small-box-footer"><i class="fa fa-arrow-circle-right"></i>
                                </a>
                            </div>
                        </div>

                        <div class="col-lg-3 col-xs-6">
                            <!-- small box -->
                            <div class="small-box bg-aqua">
                                <div class="inner">
                                    <h3>150
                                    </h3>
                                    <p>
                                        Acopio y Reciclaje
                                   
                                    </p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-bag"></i>
                                </div>
                                <a href="#" class="small-box-footer"><i class="fa fa-arrow-circle-right"></i>
                                </a>
                            </div>
                        </div>

                    </div>
                    <div id="divMap" style="padding: 5px; background: white; box-shadow: 0px 1px 4px rgba(0,0,0,0.2); margin-bottom: 6px;">
                        <div>
                            <h4>Map Results</h4>
                        </div>
                        <div id="map-canvas" style="width: 100%; height: 400px;" align="center"></div>
                    </div>
                </section>
                <!-- /.content -->
            </aside>
            <!-- /.right-side -->
        </div>
    </form>
</body>
</html>

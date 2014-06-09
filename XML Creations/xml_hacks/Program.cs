using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml.Serialization;

namespace data_conversions
{
    class Program
    {

        static LocationDataset dataSet = new LocationDataset();

        static void Main(string[] args)
        {
            LoadSchoolData();
            LoadCDTData();
            LoadWifiData();
            LoadAcopioYReciclajeData();
            //LoadHospitalData();
        }

        static void LoadAcopioYReciclajeData()
        {
            string filename = @"C:\users\encoded\desktop\data_raw\installaciones.csv";
            int lastID = dataSet.getLocations().Count + 1;
            StreamReader reader = new StreamReader(File.OpenRead(filename));
            string data = reader.ReadToEnd();
            string[] lines = data.Split('\n');

            foreach (string line in lines)
            {
                string[] line_data = line.Split('\t');
                try
                {
                    dataSet.AddLocation(
                        new Location()
                        {
                            Id = lastID++,
                            Name = line_data[1],
                            Description = line_data[5] + " " + line_data[6],
                            Address = line_data[8] + " " + line_data[9],
                            Telephone = line_data[7],
                            Latitude = double.Parse(line_data[2]),
                            Longitude = double.Parse(line_data[3]),
                            Type = "Acopio y Reciclaje"

                        });
                }
                catch
                {
                }

            }
        }

        static void LoadWifiData()
        {
            string filename = @"C:\users\encoded\desktop\data_raw\wifi.csv";
            int lastID = dataSet.getLocations().Count + 1;
            StreamReader reader = new StreamReader(File.OpenRead(filename));
            string data = reader.ReadToEnd();
            string[] lines = data.Split('\n');

            foreach (string line in lines)
            {
                string[] line_data = line.Split('\t');
                try
                {
                    dataSet.AddLocation(
                        new Location()
                        {
                            Id = lastID++,
                            Name = line_data[0],
                            Description = "",
                            Address = line_data[1],
                            Telephone = "",
                            Latitude = double.Parse(line_data[2]),
                            Longitude = double.Parse(line_data[3]),
                            Type = "WIFI"

                        });
                }
                catch
                {
                }

            }
        }

        //static void LoadHospitalData()
        //{
        //    string filename = @"C:\users\encoded\desktop\data_raw\Hospitales_2009.csv";
        //    int lastID = locations.Count + 1;
        //    StreamReader reader = new StreamReader(File.OpenRead(filename));
        //    string data = reader.ReadToEnd();
        //    string[] lines = data.Split('\n');

        //    foreach (string line in lines)
        //    {
        //        string[] line_data = line.Split('\t');
        //        try
        //        {
        //            locations.Add(
        //                new Location()
        //                {
        //                    Id = lastID++,
        //                    Name = line_data[0],
        //                    Description = line_data[13] + line_data[14],
        //                    Address = line_data[2].Replace('\"', ' ') + " " + line_data[3] + " " + line_data[4] + " " + line_data[5],
        //                    Telephone = line_data[7],
        //                    Latitude = double.Parse(line_data[9]) - 170029.88878666156765,
        //                    Longitude = double.Parse(line_data[10]) - 270788.09415356896792,
        //                    Type = "Hospital"

        //                });
        //        }
        //        catch(Exception ex)
        //        {
        //            Console.WriteLine(ex.Message);
        //        }


        //    }
        //}

        static void LoadCDTData()
        {
            string filename = @"C:\users\encoded\desktop\data_raw\cdt_2009.csv";
            int lastID = dataSet.getLocations().Count + 1;
            StreamReader reader = new StreamReader(File.OpenRead(filename));
            string data = reader.ReadToEnd();
            string[] lines = data.Split('\n');

            foreach (string line in lines)
            {
                string[] line_data = line.Split('\t');
                try
                {
                    dataSet.AddLocation(
                        new Location()
                        {
                            Id = lastID++,
                            Name = line_data[4],
                            Description = line_data[9],
                            Address = line_data[8].Replace('\"', ' '),
                            Telephone = "",
                            Latitude = double.Parse(line_data[1]),
                            Longitude = double.Parse(line_data[2]),
                            Type = "CDT"

                        });
                }
                catch
                {
                }

            }
        }

        static void LoadSchoolData()
        {
            string filename = @"C:\users\encoded\desktop\data_raw\school_wan.csv";
            int lastID = dataSet.getLocations().Count + 1;
            StreamReader reader = new StreamReader(File.OpenRead(filename));
            string data = reader.ReadToEnd();
            string[] lines = data.Split('\n');

            foreach (string line in lines)
            {
                string[] line_data = line.Split(',');
                try
                {
                    dataSet.AddLocation(
                        new Location()
                        {
                            Id = lastID++,
                            Name = line_data[4],
                            Description = "Escuela: " + line_data[1],
                            Address = line_data[7] + " " + line_data[8] + " " + line_data[9] + " " + line_data[10] + " " + line_data[11],
                            Telephone = line_data[12],
                            Latitude = double.Parse(line_data[5]),
                            Longitude = double.Parse(line_data[6]),
                            Type = "Escuela"

                        });
                }
                catch
                {
                }


            }
        }

        //based on sql function
        static string CalculateLambertCoordinates(double Northing, double Easting)
        {
           ////////////////////////////////////////////////////////////////////////////////
           //WGS-84
           //@a real=6378137.0,                                                     //Need the real value here! - Semi-major axis of reference ellipsoid WGS-84
           //@flattening real=1.0/(298.257223563),             //Need the real value here! - Ellipsoidal flattening
           ////////////////////////////////////////////////////////////////////////////////
       
           ////////////////////////////////////////////////////////////////////////////////
           //Data para Puerto Rico!!!!
           //San Juan 18.45 N, -66.1 W = Lat, Lon
           ////////////////////////////////////////////////////////////////////////////////
       
           ////////////////////////////////////////////////////////////////////////////////
           //3992 - Puerto Rico / St. Croix
           //////////////////////////////////////////////////////////////////////////////////
           //Projection Parameters ( Lambert Conformal Conic 2SP )
           //Parameter                                   Value
           //False Northin                               100000
           //False Easting                               500000
           //Origin Latitude (degrees)            17.8333333333333
           //Origin Longitude (degrees)     -66.4333333333334
           //Parallel North (degrees)       18.4333333333333
           //Parallel South (degrees)       18.0333333333333
           //Scale Factor                                0
           //////////////////////////////////////////////////////////////////////////////////
           //Map Datum Parameters ( Puerto Rico )
           //Parameter                                   Value
           //Map Datum Name                       Puerto Rico
           //EPSG CRS #                           4139
           //Ellipsoid Name                       Clarke 1866
           //Semi Major Axis                      6378206.4
           //Inverse Flattening                   294.978698213898
           //Conversion                           Molodensky (3 Parameter)
           //Translation X (meters)         11.00
           //Translation Y (meters)         72.00
           //Translation Z (meters)         -101.00
           ////////////////////////////////////////////////////////////////////////////////

           ////////////////////////////////////////////////////////////////////////////////
           //3991 - Puerto Rico State Plane CS of 1927
           ////////////////////////////////////////////////////////////////////////////////
           //Projection Parameters ( Lambert Conformal Conic 2SP )
           //Parameter                                   Value
           //False Northing                       0
           //False Easting                               500000
           //Origin Latitude (degrees)            17.8333333333333
           //Origin Longitude (degrees)     -66.4333333333334
           //Parallel North (degrees)       18.4333333333333
           //Parallel South (degrees)       18.0333333333333
           //Scale Factor                                0
           ////////////////////////////////////////////////////////////////////////////////
           //Map Datum Parameters ( Puerto Rico )
           //Parameter                                   Value
           //Map Datum Name                       Puerto Rico
           //EPSG CRS #                           4139
           //Ellipsoid Name                       Clarke 1866
           //Semi Major Axis                      6378206.4
           //Inverse Flattening                   294.978698213898
           //Conversion                           Molodensky (3 Parameter)
           //Translation X (meters)         11.00
           //Translation Y (meters)         72.00
           //Translation Z (meters)         -101.00
           ////////////////////////////////////////////////////////////////////////////////

           ////////////////////////////////////////////////////////////////////////////////
           //Puerto Rico and Virgin Islands FIPS 5200 Parameters (NAD83 Datum)
           //                                            Deg Min.Min                      Decimal Degrees
           //Central Meridian               66° 26'                                 66.43°
           //Latitude of Origin             17° 50'                                 17.83°
           //Standard Parallel #1           18° 02'                                 18.03°
           //Standard Parallel #2           18° 26'                                 18.43°
           //False Easting                        200000 meters
           //False Northing                 200000 meters
           //Puerto Rico and Virgin Islands uses a Lambert Projection.
           ////////////////////////////////////////////////////////////////////////////////

           ////////////////////////////////////////////////////////////////////////////////
           //DATA PARA VALIDACIÓN DE FORMULAS
           //Parameters:
           //Ellipsoid  Clarke 1866, a = 6378206.400 metres = 20925832.16 US survey feet
           //                                                     1/f = 294.97870
           //then e = 0.08227185 and e^2 = 0.00676866

           //First Standard Parallel          28o23'00""N  =   0.49538262 rad
           //Second Standard Parallel    30o17'00""N  =   0.52854388 rad
           //Latitude False Origin            27o50'00""N  =   0.48578331 rad
           //Longitude False Origin         99o00'00""W = -1.72787596 rad
           //Easting at false origin           2000000.00  US survey feet
           //Northing at false origin          0.00  US survey feet

           //Forward calculation for: 
           //Latitude       28o30'00.00""N  =  0.49741884 rad
           //Longitude         96o00'00.00""W = -1.67551608 rad

           //first gives :
           //m1    = 0.88046050      m2 = 0.86428642
           //t        = 0.59686306      tF  = 0.60475101
           //t1      = 0.59823957      t2 = 0.57602212
           //n       = 0.48991263       F = 2.31154807
           //r        = 37565039.86    rF = 37807441.20
           //theta = 0.02565177

           //Then Easting E =      2963503.91 US survey feet
           //       Northing N =      254759.80 US survey feet

           //Reverse calculation for same easting and northing first gives:
           //theta' = 0.025651765     r' = 37565039.86
           //t'        = 0.59686306

           //Then Latitude      = 28o30'00.000""N
           //           Longitude   = 96o00'00.000""W
           ////////////////////////////////////////////////////////////////////////////////

           //Vamos  a asumir que los datos de Northing y Easting están en pies


            
           double a =6378137.0;//*100.0/2.54/12.0;               //Need the real value here! - Semi-major axis of reference ellipsoid WGS-84
           double flattening =1.0/(298.257223563);               //Need the real value here! - Ellipsoidal flattening
           double la1 =18.4333333333333*(2.0*Math.PI/360.0); //(28.0+(23.0/60.0))*(2.0*Math.PI/360.0);   //Latitude of first standard parallel
           double la2 =18.0333333333333*(2.0*Math.PI/360.0); //(30.0+(17.0/60.0))*(2.0*Math.PI/360.0);   //Latitude of second standard parallel
           double la0 =17.8333333333333*(2.0*Math.PI/360.0); //(27.0+(50.0/60.0))*(2.0*Math.PI/360.0);   //Origin latitude N-S
           double lo0 =-66.4333333333334*(2.0*Math.PI/360.0);//-(99.0+(0.0/60.0))*(2.0*Math.PI/360.0);  //Origin longitude E-W
           double n0 =200000.0;//*100.0/2.54/12.0;                                                //False Northing
           double e0 =200000.0;//*100.0/2.54/12.0;                                                //False Easting
           double la;
           double lo;
           double no;
           double ea;
           double F;
           double p;
           double n;
           double e;
           double m1;
           double m2;
           double t0;
           double t1;
           double t2;
           double p0;
           double latitude;
           double longitude;
           double n_prime;
           double e_prime;
           double p_prime;
           double t_prime;
           double theta_prime;
           double gamma_prime;
           int i =0;


            //Primeras formulas:
            n_prime = Northing - n0;
            e_prime = Easting - e0;
            e = Math.Sqrt((2.0*flattening)-Math.Pow(flattening,2.0));
            m1 = Math.Cos(la1)/Math.Sqrt(1.0-(Math.Pow(e,2.0)*Math.Pow(Math.Sin(la1),2.0)));
            m2 = Math.Cos(la2)/Math.Sqrt(1.0-(Math.Pow(e,2.0)*Math.Pow(Math.Sin(la2),2.0)));
            t0 = Math.Tan((Math.PI/4.0)-(la0/2.0))/Math.Pow(((1.0-(e*Math.Sin(la0)))/(1.0+(e*Math.Sin(la0)))),(e/2.0));
            t1 = Math.Tan((Math.PI/4.0)-(la1/2.0))/Math.Pow(((1.0-(e*Math.Sin(la1)))/(1.0+(e*Math.Sin(la1)))),(e/2.0));
            t2 = Math.Tan((Math.PI/4.0)-(la2/2.0))/Math.Pow(((1.0-(e*Math.Sin(la2)))/(1.0+(e*Math.Sin(la2)))),(e/2.0));
            n = (Math.Log(m1)-Math.Log(m2))/(Math.Log(t1)-Math.Log(t2));
            F = (m1)/((n)*Math.Pow((t1),n));
            p0 = a*F*Math.Pow(t0,n);
            p_prime = Math.Sign(n)*Math.Sqrt(Math.Pow(e_prime,2.0)+Math.Pow(p0-n_prime,2.0));
            t_prime = Math.Pow((p_prime)/(a*F),1.0/n);
            gamma_prime = a*Math.Tan(e_prime/(p0-n_prime));
       
           //Comienza iteración
           latitude = ((Math.PI/2.0)-(2.0*a * Math.Tan(t_prime)));
       
           while (i <= 2)
           {
                 latitude = (Math.PI/2.0)-(2.0*a*Math.Tan(t_prime*Math.Pow((1-e*Math.Sin(latitude))/(1+e*Math.Sin(latitude)),(e/2.0))));
                 i++;
           }
       
           //Back to degrees:
           latitude = latitude * (360.0 / (2.0 * Math.PI));                       
           longitude = ((gamma_prime/n)+lo0)*(360.0/(2.0*Math.PI));
       

           return string.Format("{0}, {1}", latitude, longitude);
           //Guardar los cálculos:
           //set geo_point = geography::STGeomFromText('POINT('+Convert(varchar,convert(decimal(30,7),longitude))+' '+Convert(varchar,convert(decimal(30,7),latitude))+')',4326)
       
           //Devolver resultado:
           //return geo_point


        }
    }
}

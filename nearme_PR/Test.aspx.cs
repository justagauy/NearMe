using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace nearme_PR
{
    public partial class Test : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //List<string> list = new List<string>() { "CDT", "Escuela", "WIFI", "Acopio y Reciclaje" };

        }

        /// <summary>
        /// fields[0] = locationType(int32)
        /// </summary>
        /// <param name="fields"></param>
        /// <returns></returns>
        [System.Web.Services.WebMethod]
        public static List<nearme_PR.Classes.Location> GetLocationsByType(string[] fields)
        {
            String locationType = fields[0];

            nearme_PR.Classes.LocationDataset ds = new Classes.LocationDataset();
            ds.LoadLocations();
            List<nearme_PR.Classes.Location> lstLocs = ds.getLocationsByType(locationType);

            return lstLocs;
        }

        /// <summary>
        /// fields[0] = Name
        /// fields[1] = Descripcion
        /// fields[2] = Categoria(String)
        /// fields[3] = lat
        /// fields[4] = lon
        /// </summary>
        /// <param name="fields"></param>
        /// <returns>Empty string if succeded, ErrMsg otherwise.</returns>
        [System.Web.Services.WebMethod]
        public static String AddLocation(string[] fields)
        {
            String ret = String.Empty;

            try
            {
                String name = fields[0];
                String description = fields[1];
                String cat = fields[2];
                Double lat = Convert.ToDouble(fields[3]);
                Double lon = Convert.ToDouble(fields[4]);

                nearme_PR.Classes.Location loc = new Classes.Location()
                {
                    Name = name,
                    Description = description,
                    Type = cat,
                    Latitude = lat,
                    Longitude = lon
                };

                nearme_PR.Classes.LocationDataset ds = new Classes.LocationDataset();
                ds.LoadLocations();
                ds.AddLocation(loc);
            }
            catch (Exception ex)
            {
                ret = ex.Message;
            }

            return ret;
        } 

    }
}
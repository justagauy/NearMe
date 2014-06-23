using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace nearme_PR
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //List<string> list = new List<string>() { "CDT", "Escuela", "WIFI", "Acopio y Reciclaje" };
            //rptType.DataSource = list;
            //rptType.DataBind();

            Response.Redirect("Test.aspx");
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

    }
}

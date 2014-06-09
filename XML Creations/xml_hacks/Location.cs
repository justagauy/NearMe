using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml.Serialization;

namespace data_conversions
{

    [Serializable()]
    public class Location
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string Address { get; set; }
        public string Telephone { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string Type { get; set; }

    }

    public class LocationDataset
    {
        private List<Location> locations = new List<Location>();

        public LocationDataset()
        {
            
        }

        public List<Location> getLocationsByType(string type)
        {
            return locations.Where(t => t.Type == type).ToList();
        }

        public List<Location> getLocations()
        {
            return locations;
        }

        public void AddLocation(Location loc)
        {
            locations.Add(loc);
            SaveLocations();
        }

        public void DeleteLocation(int locId)
        {
            foreach(Location loc in locations)
            {
                if(locId == loc.Id)
                    locations.Remove(loc);
            }

            SaveLocations();
        }

        public void LoadLocations()
        {
            string filename = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments, Environment.SpecialFolderOption.Create) + "\\nearme\\locations.xml";
            using (StreamReader reader = new StreamReader(filename))
            {

                try
                {
                    XmlSerializer serializer = new XmlSerializer(typeof(List<Location>));

                    locations = (List<Location>)serializer.Deserialize(reader);
                }
                catch
                {
                }
            }
        }

        private void SaveLocations()
        {
            string filename = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments, Environment.SpecialFolderOption.Create) + "\\nearme\\locations.xml";
            
            XmlSerializer serializer = new XmlSerializer(typeof(List<Location>));
            StreamWriter writer = new StreamWriter(File.Open(filename, FileMode.OpenOrCreate));

            serializer.Serialize(writer, locations);
            writer.Close();
        }
    }

}

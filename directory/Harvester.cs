using System;
using System.Net;
using System.IO;
using System.Xml.Serialization;
using oai;
using System.Text;
using System.Collections;
using log4net;

using registry;

namespace Replicate
{
	public class Harvester
	{
        public static VOR_XML vorXML = new VOR_XML();

		public static string XMLHEADER = @"<?xml version=""1.0"" encoding=""UTF-8""?>";

        private static string dbAdmin = (string)System.Configuration.ConfigurationManager.AppSettings["dbAdmin"];
        private static string log_location = (string)System.Configuration.ConfigurationManager.AppSettings["log_location"];
        public static string logFileName = log_location + "\\replicatelog.txt"; 

		public static StringBuilder sb = new StringBuilder();

        private logfile errLog;

        private ArrayList knownbad = new ArrayList();
		private static readonly ILog log = LogManager.GetLogger (typeof(Harvester));

        public Harvester()
        {
            errLog = new logfile("err_HarvesterService.log");

            //newer SSL connections require this, including HEASARC.
            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;

            //These are known bad records to be managed by hand.
            //Note we can just delete bad records if they were already imported
            //and falsely validated.
            //If they're in this list, they've repeatedly failed to import properly
            //and been caught in the harvest logs. Putting them on this list will allow
            //them to be skipped, keeping the harvester from re-importing ALL records from
            //a publishing registry after the date of first failure, in perpetuity until 
            //the record is fixed (which may never happen).
            try
            {
                string appDir = System.Web.Hosting.HostingEnvironment.ApplicationPhysicalPath;
                string file = appDir + "known_bad_records.txt";
 
                using (System.IO.StreamReader sr = new System.IO.StreamReader(file))
                {
                    string line;
                    while( (line = sr.ReadLine()) != null)
                        knownbad.Add(line);
                }
            }
            catch (Exception) { }

        }

        //todo: refactor: record deletion goes here, remove it from registrydbquery
		public string harvest(string baseurl, string registryID, string extraParams) 
		{
            string connect = (string)System.Configuration.ConfigurationManager.AppSettings["SqlAdminConnection"];
            if (null == connect)
                connect = (string)System.Configuration.ConfigurationManager.AppSettings["SqlConnection"];
			if (null == connect) connect = "bad connection string";
			RegistryDBQuery reg = new RegistryDBQuery(connect);
			string url= "";

			if ( baseurl.Contains("?"))
				url = baseurl + extraParams;
            else
				url = baseurl + "?" + extraParams;

			bool nextToken = true;
			string rt = null;
			StringBuilder sb = new StringBuilder();

            int recFailures = 0;
            int recSkipped = 0;
			while (nextToken)
			{
                try
                {
                    if (rt != null)
                    {
                        if (baseurl.EndsWith("?"))
                            url = baseurl + "verb=ListRecords&resumptionToken=" + rt;
                        else
                            url = baseurl + "?verb=ListRecords&resumptionToken=" + rt;
                    }
                    sb.Append(DateTime.Now + " Harvesting " + url);
                    Console.Out.WriteLine(DateTime.Now + " Harvesting " + url);
                    HttpWebRequest wr = (HttpWebRequest)WebRequest.Create(url);

                    HttpWebResponse resp = null;
                    try
                    {
                        resp = (HttpWebResponse)wr.GetResponse();
                    }
                    catch (Exception e)
                    {
                        sb.Append(" Harvester Error: " + e.Message );
                    }
                    if (resp == null)
                        return sb.ToString();

                    // Gets the stream associated with the response.
                    Stream receiveStream = resp.GetResponseStream();
                    Encoding encode = System.Text.Encoding.GetEncoding("utf-8");
                    // Pipes the stream to a higher level stream reader with the required encoding format. 
                    StreamReader stream = new StreamReader(receiveStream, encode);

                    // it is OAI we presume so make a serializer for it
                    // of course, several registries are giving back noncompliant errors on "no records"
                    // so we're going out on a limb here and guessing that's what deserialisation errors are.
                    OAIPMHtype oai = null;
                    try
                    {
                        XmlSerializer ser = new XmlSerializer(typeof(OAIPMHtype));
                        oai = (OAIPMHtype)ser.Deserialize(stream);

                        if (oai.Items[0] is oai.OAIPMHerrorType)
                        {
                            OAIPMHerrorType err = oai.Items[0] as OAIPMHerrorType;
                            if (err.code == OAIPMHerrorcodeType.noRecordsMatch)
                                return "No Records to Harvest";
                            else if (err.code == OAIPMHerrorcodeType.idDoesNotExist)
                                return "Individual record does not exist";

                            sb.Append("\nOAI Error :");
                            sb.Append(((OAIPMHerrorType)oai.Items[0]).Value);

                            throw new Exception(sb.ToString());
                        }
                    }
                    catch (System.NullReferenceException)
                    {
                        //OAIPMHerrorType err = new OAIPMHerrorType();
                        //err.code = OAIPMHerrorcodeType.noRecordsMatch;
                        return "No Records to Harvest";
                    }
					catch (InvalidOperationException ex)
					{
						log.Error("Error during harvest of url " + url,ex);
						// Catches errors parsing XML 
						return "Error: " + ex.Message;
					}
					catch (Exception ex)
					{
						return "Error: " + ex.Message + "No Records to Harvest";
					}
 
                    try
                    {
                        if (oai.Items[0].GetType() == typeof(ListRecordsType))
                        {
                            if (((ListRecordsType)oai.Items[0]).resumptionToken == null)
                                rt = null;
                            else
                                rt = ((ListRecordsType)oai.Items[0]).resumptionToken.Value;
                        }
                    }
                    catch (Exception se)
                    {
                        sb.Append(se + " : Problem Resumption Token" + se.Message);
                    }

                    nextToken = rt != null && rt.Length > 0;


                    recordType[] recs = null;

                    try
                    {
                        if (oai.Items[0].GetType() == typeof(ListRecordsType))
                        {
                            recs = ((ListRecordsType)oai.Items[0]).record;
                        }
                        else
                        {
                            recs = new recordType[1];
                            recs[0] = ((GetRecordType)oai.Items[0]).record;
                        }
                    }
                    catch
                    {
                        sb.Append("\nGot no records :" + oai.Items[0] + "\n");
                        return sb.ToString();
                    }
                    if (recs == null)
                    {
                        return "No Records to Harvest";
                    }

                    sb.Append(" \nGot " + recs.Length + " recs\n");
                    Console.Out.WriteLine(" \nGot " + recs.Length + " recs\n");

                    ArrayList res = new ArrayList();
                    DateTime now = DateTime.Now;
                    string theXML = null;
                    for (int r = 0; r < recs.Length; r++)
                    {
                        string id = recs[r].header.identifier.Trim();

                        //Console.Out.WriteLine(r+"  resources "+recs[r].metadata);
                        if (recs[r].header.status == statusType.deleted)
                        {

                            StringBuilder sbOut = new StringBuilder();
                            int status = vorXML.DeleteVORXML(id, 0, baseurl, registryID, sbOut);
                            sb.Append("\nDelete id: " + id + " " + sbOut.ToString() + "\n");
                        }
                        else
                        {
                            //These are known bad records to be managed by hand.
                            //If they're in this list, they've repeatedly failed to import properly
                            //and been caught in the logs by a human operator.
                            if (knownbad.Contains(id))
                            {
                                ++recSkipped;
                                continue;
                            }

                            try
                            {
                                //Do not store the XML Header for instances of selecting
                                //and concatenating xml resources.
                                //theXML = XMLHEADER+recs[r].metadata.OuterXml;
                                theXML = recs[r].metadata.OuterXml;
                            }
                            catch
                            {
                                sb.Append(" \nAt rec=" + r + " " + recs[r].metadata);
                            }
                            // Load single resource in the Registry
                            try
                            {
                                string harvestURL = baseurl;
                                if (harvestURL.Contains("?"))
                                    harvestURL = harvestURL.Substring(0, harvestURL.IndexOf('?'));

                                //misc cleanup of records from other publishers.
                                theXML = theXML.Replace(" xmlns=\"http://www.openarchives.org/OAI/2.0/\"", "");
                                if (!theXML.Contains("http://www.w3.org/2001/XMLSchema-instance"))
                                {
                                    int index = theXML.IndexOf("xmlns=");
                                    theXML = theXML.Insert(index, "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ");
                                }

                                int status = 0;
                                try
                                {
                                    status = vorXML.LoadVORXML(theXML, 0, harvestURL, registryID, sb);
                                    if (status != 0)
                                    {
                                        ++recFailures;
                        
                                        Console.Out.WriteLine("Failed to harvest resource " + id + ".\n" +
                                                               "Err is " + sb.ToString());                  
                                        errLog.Log("Failed to harvest resource " + id + ".\n" +
                                                   "Err is " + sb.ToString());
                                    }
                                }
                                catch (System.IO.IOException)
                                {
                                    status = -1;
                                    //if we can't write to the logfile there's no 
                                    //point in trying to log that....
                                }
                            }

                            catch (Exception se)
                            {
                                try
                                {
                                    ++recFailures;
                                    Console.Out.WriteLine(se + ":" + se.StackTrace);
                                    sb.Append(se + ": " + se.StackTrace + "\n");
                                    errLog.Log("Exception harvesting resource. " +
                                        "Message is: " + se.Message);

                                }
                                catch (System.IO.IOException)
                                {
                                    //if we can't write to the logfile there's no 
                                    //point in trying to log that....
                                }
                            }
                        }
                    }

                    sb.Append("Loaded " + (recs.Length - recFailures - recSkipped) + " RESOURCES. ");
                    if (recSkipped > 0)
                        sb.Append("Skipped " + recSkipped + " RESOURCES from known bad list. ");
                    if (recFailures > 0)
                        sb.Append("Failed to load " + recFailures + " RESOURCES. ");
                }
                catch (Exception ex)
                {
                    sb.Append("Uncaught Exception in harvesting " + baseurl + " : " + ex);
                }
			}

			return sb.ToString();
		}
	}
}
<%@ WebHandler Language="C#" Class="Twilio_Webhook" %>

using System;
using System.Collections.Generic;
using System.Web;
using System.Collections.Specialized;
using System.Text;
using Newtonsoft.Json;

public class Twilio_Webhook : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";

        try
        {
            //Log the message id and status
            var smsSid = HttpContext.Current.Request.Form["SmsSid"];
            var from = HttpContext.Current.Request.Form["From"];
            var to = HttpContext.Current.Request.Form["To"];
            var body = HttpContext.Current.Request.Form["Body"];
            var messageStatus = HttpContext.Current.Request.Form["MessageStatus"];
            var eventdate = DateTime.Now.ToString("yyyy-MM-d HH:mm:ss");

            List<TwilioSMS> TwilioSMS = new List<TwilioSMS>();
            TwilioSMS.Add(new TwilioSMS { smsSid = smsSid, from = from, to = to, body = body, messageStatus = messageStatus, eventdate = eventdate });
            var rawTwilioSMSJSON = JsonConvert.SerializeObject(TwilioSMS);

            SaveTwilioSMSDeliveryStatus(to, "2", messageStatus, eventdate,smsSid);

            context.Response.Write("OK, JSON: " + rawTwilioSMSJSON);
        }
        catch (Exception ex)
        {
            ProcLibrary.ErrorHandler('W', ex);
            context.Response.Write(ex.Message);
        }
    }

    public static void SaveTwilioSMSDeliveryStatus(string Recipient, string OutreachType, string Action, string EventDate,string ReferenceID)
    {
        string SQL = @"dbo.SaveSMS Data";
        NameValueCollection collection = new NameValueCollection();

        collection.Add("Recipient", Recipient);
        collection.Add("OutreachType", OutreachType);
        collection.Add("Action", Action);
        collection.Add("EventDate", EventDate);
        collection.Add("ReferenceID", ReferenceID);

        ProcLibrary.CallProcedureGetJSON("Test", SQL, collection);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

public class TwilioSMS
{
    public string smsSid { get; set; }
    public string from { get; set; }
    public string to { get; set; }
    public string body { get; set; }
    public string messageStatus { get; set; }
    public string eventdate { get; set; }
}
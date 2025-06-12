<%@ Page Aspcompat="true" Language="VB" %>
<%@ Import Namespace="argo.web" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.xml" %>
<%@ Import Namespace="System.xml.xPath" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="APToolkitNET" %>

<script type="text/vb" runat="server">
Protected Sub Page_Load(ByVal sender As Object, ByVal args As System.EventArgs) Handles Me.Load
    Response.Buffer = True
    Response.Expires = 0
    Response.Clear()
    
    Dim objToolkit As New Toolkit()
    
    'Set Toolkit Registration Codes
    objToolkit.SetRegistrationCode(ConfigurationManager.AppSettings("ActivePdfUserCode"), ConfigurationManager.AppSettings("ActivePdfRuntimeCode"))
    
    NoticeofHoldReceiptPDFGen(objToolkit)
End Sub

Protected Sub NoticeofHoldReceiptPDFGen(ByVal objToolkit As Toolkit)
    Try
        Dim fileInName As String = Nothing
        Dim uniquePdfName As String = objToolkit.GetUniqueFileName
        Dim fileOutName As String = GenerateName(uniquePdfName)
        Dim intReturn As Integer = 0
        
        ' Get all form values
        Dim txtPD As String = WebUtils.GetRequestValue(Request, "txtPD")
        Dim txtCD As String = WebUtils.GetRequestValue(Request, "txtCD")
        Dim depositAmount As String = WebUtils.GetRequestValue(Request, "depositAmount")
        Dim accountNumber As String = WebUtils.GetRequestValue(Request, "accountNumber")
        Dim holdAmount As String = WebUtils.GetRequestValue(Request, "holdAmount")
        Dim availableDate As String = WebUtils.GetRequestValue(Request, "availableDate")
        Dim holdReason As String = WebUtils.GetRequestValue(Request, "holdReason")
        
        fileInName = String.Concat(Server.MapPath("."), "\pdfNoticeofHoldReceipt.pdf")
        
        If fileInName <> Nothing Then
            'Open the output file and store it in memory
            intReturn = objToolkit.OpenOutputFile(fileOutName)
            If intReturn <> 0 Then
                Response.Write(String.Concat("OpenOutputFile failed with a return code of: ", intReturn, "<br>"))
                Response.End()
            End If
            
            'Open the input file
            intReturn = objToolkit.OpenInputFile(fileInName)
            If intReturn <> 0 Then
                Response.Write(String.Concat("OpenInputFile failed with a return code of: ", intReturn, "<br>"))
                Response.End()
            End If

            ' Set all PDF form fields
            Try
                ' Main content fields
                objToolkit.SetFormFieldData("txtPD", txtPD, 0)
                objToolkit.SetFormFieldData("txtCD", txtCD, 0)
                
                ' Transaction details
                objToolkit.SetFormFieldData("depositAmount", depositAmount, 0)
                objToolkit.SetFormFieldData("accountNumber", accountNumber, 0)
                
                ' Hold details
                objToolkit.SetFormFieldData("holdAmount", holdAmount, 0)
                objToolkit.SetFormFieldData("availableDate", availableDate, 0)
                objToolkit.SetFormFieldData("holdReason", holdReason, 0)
                
                ' Log the values for debugging
                Logging.Write(String.Format("Setting PDF fields - PD: {0}, CD: {1}, Amount: {2}, Account: {3}, Hold: {4}, Available: {5}", 
                    txtPD,
                    txtCD,
                    depositAmount,
                    accountNumber,
                    holdAmount,
                    availableDate))
                
            Catch ex As Exception
                Logging.Write(String.Format("Error setting PDF fields: {0}", ex.Message))
                Throw
            End Try
            
            'Copy the form with updated values
            intReturn = objToolkit.CopyForm(0, 0)
            If intReturn <> 1 Then
                Response.Write(String.Concat("CopyForm failed with a return code of: ", intReturn, "<br>"))
                Response.End()
            End If
            
            'Flatten form fields to make them non-editable in the final PDF
            objToolkit.FlattenRemainingFormFields = 1
            
            'Close and save the output file
            objToolkit.CloseOutputFile()
            
            'Set response headers for PDF download
            Response.Clear()
            Response.ContentType = "application/pdf"
            Response.AddHeader("Content-Disposition", String.Format("attachment; filename=NoticeOfHoldReceipt_{0}.pdf", DateTime.Now.ToString("yyyyMMdd_HHmmss")))
            
            'Stream the PDF to client
            Response.TransmitFile(fileOutName)
            Response.End()
        End If
    Catch ex As Exception
        Logging.Write(String.Format("Error in NoticeofHoldReceiptPDFGen: {0}", ex.Message))
        Response.Write(String.Format("Error generating PDF: {0}", ex.Message))
        Response.End()
    Finally
        'Remove reference
        objToolkit = Nothing
    End Try
End Sub

Protected Function GenerateName(ByVal uniquePdfName As String) As String
    ' Generate Output File Name
    Dim fileOutName As String = String.Concat(Server.MapPath("~\download"), "\", uniquePdfName)
    Return fileOutName
End Function

Protected Function GenerateURL(ByVal uniquePdfName As String) As String
    ' Get URL to return to client
    Dim absolutePath As String = Request.Url.AbsolutePath
    Dim url As String = Request.Url.AbsoluteUri
    url = url.Replace(absolutePath, Page.ResolveUrl(String.Concat("~/download/", uniquePdfName)))
    Return url
End Function
</script> 
function closeReceipt() {
    try {
        Logging.Write("[TELLER][SESSION SUMMARY][session_summary.js] function closeReceipt() - entering");
        
        // Get values from the popup
        var pdValue = document.getElementById("divHeader").innerText.match(/PD\s+(\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}\s+#\s+\d+)/)?.[1] || "";
        var cdValue = document.getElementById("divHeader").innerText.match(/CD\s+(\d{2}\/\d{2}\/\d{4}\s+\d+\s+\d+\s+\d+)/)?.[1] || "";
        var depositAmount = document.getElementById("divBody").innerText.match(/Commercial\s+Deposit\s+\$?([\d,]+\.\d{2})/)?.[1] || "";
        var accountNumber = document.getElementById("divBody").innerText.match(/Chk\/Sav\/MMA\s+(\w+)/)?.[1] || "";
        
        // Get hold notice details
        var holdNotice = document.getElementById("divFooter").innerText;
        var holdAmount = holdNotice.match(/\$?([\d,]+\.\d{2})\s+FROM\s+YOUR\s+DEPOSIT/)?.[1] || "";
        var availableDate = holdNotice.match(/AVAILABLE\s+ON\s+(\d{2}\/\d{2}\/\d{4})/)?.[1] || "";
        var holdReason = holdNotice.match(/BECAUSE\s+(.+?)(?=\n|$)/)?.[1] || "";

        // Set form values
        var form = document.forms["formBackgroundPrint"];
        form.hiddenPDFName.value = "\\pdf\\NoticeofHoldReceipt.pdf";
        form.txtPD.value = pdValue;
        form.txtCD.value = cdValue;
        
        // Add new hidden fields for additional values
        if (!form.depositAmount) {
            var depositAmountInput = document.createElement("input");
            depositAmountInput.type = "hidden";
            depositAmountInput.name = "depositAmount";
            depositAmountInput.value = depositAmount;
            form.appendChild(depositAmountInput);
        }
        
        if (!form.accountNumber) {
            var accountNumberInput = document.createElement("input");
            accountNumberInput.type = "hidden";
            accountNumberInput.name = "accountNumber";
            accountNumberInput.value = accountNumber;
            form.appendChild(accountNumberInput);
        }
        
        if (!form.holdAmount) {
            var holdAmountInput = document.createElement("input");
            holdAmountInput.type = "hidden";
            holdAmountInput.name = "holdAmount";
            holdAmountInput.value = holdAmount;
            form.appendChild(holdAmountInput);
        }
        
        if (!form.availableDate) {
            var availableDateInput = document.createElement("input");
            availableDateInput.type = "hidden";
            availableDateInput.name = "availableDate";
            availableDateInput.value = availableDate;
            form.appendChild(availableDateInput);
        }
        
        if (!form.holdReason) {
            var holdReasonInput = document.createElement("input");
            holdReasonInput.type = "hidden";
            holdReasonInput.name = "holdReason";
            holdReasonInput.value = holdReason;
            form.appendChild(holdReasonInput);
        }

        Logging.Write("[TELLER][SESSION SUMMARY][session_summary.js] closeReceipt() - Sending form values");
        
        // Submit form to generate PDF
        $(form).trigger("submit");
        
        // Wait for PDF generation and handle cleanup
        document.getElementById("iframeBuffer").wait("Generating PDF", "", function() {
            // Clean up after successful PDF generation
            RemoveFolder().then(() => {
                // Close the popup
                if (window.opener && !window.opener.closed) {
                    window.close();
                } else {
                    try {
                        $('#receiptModal').modal('hide');
                    } catch(e) {
                        document.body.style.display = 'none';
                    }
                }
            }).catch(error => {
                Logging.Write("[TELLER][SESSION SUMMARY][session_summary.js] Error in cleanup: " + error);
                alert("PDF generated but cleanup failed. Please contact administrator.");
            });
        });
        
        Logging.Write("[TELLER][SESSION SUMMARY][session_summary.js] function closeReceipt() - complete");
    } catch(error) {
        Logging.Write("[TELLER][SESSION SUMMARY][session_summary.js] Error in closeReceipt: " + error);
        alert("Error generating PDF. Please try again or contact administrator.");
    }
} 
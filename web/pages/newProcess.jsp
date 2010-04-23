<%-- 
    Document   : newProcess
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $("#newProcessWizard").dialog({
        autoOpen: false,
        width: 800,
        height: 600,
        modal: true,
        buttons: {
            'Create an account': function() {
                /*var bValid = true;
                allFields.removeClass('ui-state-error');

                bValid = bValid && checkLength(name,"username",3,16);
                bValid = bValid && checkLength(email,"email",6,80);
                bValid = bValid && checkLength(password,"password",5,16);

                bValid = bValid && checkRegexp(name,/^[a-z]([0-9a-z_])+$/i,"Username may consist of a-z, 0-9, underscores, begin with a letter.");
                // From jquery.validate.js (by joern), contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
                bValid = bValid && checkRegexp(email,/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i,"eg. ui@jquery.com");
                bValid = bValid && checkRegexp(password,/^([0-9a-zA-Z])+$/,"Password field only allow : a-z 0-9");

                if (bValid) {
                    $('#users tbody').append('<tr>' +
                        '<td>' + name.val() + '</td>' +
                        '<td>' + email.val() + '</td>' +
                        '<td>' + password.val() + '</td>' +
                        '</tr>');
                    $(this).dialog('close');
                }*/
                $(this).dialog('close');
            },
            Cancel: function() {
                $(this).dialog('close');
            }
        },
        close: function() {
            // dit goed checken!!
            allFields.val('').removeClass('ui-state-error');
            $(this).dialog("destroy");
            $("#newProcessWizardForm").formwizard("reset");
        }
    });
</script>




<!--div id="dialog-form" title="Create new user">
	<p class="validateTips">All form fields are required.</p>

	<form>
	<fieldset>
		<label for="name">Name</label>
		<input type="text" name="name" id="name" class="text ui-widget-content ui-corner-all" />
		<label for="email">Email</label>
		<input type="text" name="email" id="email" value="" class="text ui-widget-content ui-corner-all" />
		<label for="password">Password</label>
		<input type="password" name="password" id="password" value="" class="text ui-widget-content ui-corner-all" />
	</fieldset>
	</form>
</div-->


<div id="newProcessWizard" title="Create new user">
    <p class="validateTips">All form fields are required.</p>

    <form id="newProcessWizardForm" method="post" action="#">
        <div id="firstStep" class="step">
            <h1>step 1 - falls through to step 2 on next</h1>
            <input  type="text" value="" /><br />
            <input  type="text" value="" /><br />
            <input  type="text" value="" /><br />
        </div>
        <div id="secondStep" class="step">
            <h1>step 2 - branch step</h1>
            <input  type="text" value="" /><br />
            <input  type="text" value="" /><br />
            <input  type="text" value="" /><br />
            <select  class="link" >
                <option value="" >Choose the step to go to...</option>
                <option value="thirdStep" >Go to Step3</option>
                <option value="fourthStep" >Go to Step4</option>
            </select><br />
        </div>
        <div id="thirdStep" class="step submit_step">
            <h1>step 3 - submit step</h1>
            <input  type="text" value="" /><br />
            <input  type="text" value="" class="required"/><br />
        </div>
        <div id="fourthStep" class="step">
            <h1>step 4</h1>
            <input  type="text" value="" /><br />
            <input  type="text" name="email" class="required email" /><br />
        </div>
        <div id="lastStep" class="step">
            <h1>step 5 - last step</h1>
            <input  type="text" value="" /><br />
            <input  type="text" value="" /><br />
        </div>
        <input type="reset" value="Reset" />
        <input type="submit" value="Submit" />
    </form>

</div>
page 50001 CopilotAuth
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(deploymentName; deploymentName)
                {

                }
                field(endpoint; endpoint)
                {

                }
                field(serviceKey; serviceKey)
                {
                    HideValue = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SaveDetails)
            {
                Caption = 'Save';
                trigger OnAction()
                var
                    datascope: DataScope;
                    apikey: SecretText;
                begin
                    apikey := Format(serviceKey);
                    IsolatedStorage.Set('deploymentname', deploymentName, datascope::Module);
                    IsolatedStorage.Set('endpoint', endpoint, datascope::Module);
                    IsolatedStorage.Set('apikey', apikey, datascope::Module);
                end;
            }

            action(getDetails)
            {

                Caption = 'Get Saved Endpoint and Name';

                trigger OnAction()
                var
                    deploymentNameop: Text;
                    endpointop: Text;
                    datascope: DataScope;
                begin
                    IsolatedStorage.Get('deploymentname', deploymentNameop);
                    IsolatedStorage.Get('endpoint', endpointop);
                    Message(deploymentNameop);
                    Message(endpointop);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = ' Save Details', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(SaveDetails_Promoted; SaveDetails)
                {
                }
                actionref(getDetails_Promoted; getDetails)
                {
                }
            }
        }
    }

    var
        deploymentName: Text;
        endpoint: Text;
        serviceKey: Text;
}
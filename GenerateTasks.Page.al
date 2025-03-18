page 50000 "Generate Tasks"
{
    PageType = PromptDialog;
    ApplicationArea = All;
    Caption = 'Generate tasks with copilot';
    PromptMode = Prompt;
    Extensible = false;

    layout
    {
        area(Prompt)
        {
            field(ProjectDescriptionField; InputProjectDescription)
            {
                ShowCaption = false;
                MultiLine = true;
                InstructionalText = 'Please describe the project or work to be done that needs to be converted into tasks';
            }
        }

        area(PromptOptions)
        {
            // In PromptDialog pages, you can define a PromptOptions area. Here you can add different settings to tweak the output that Copilot will generate.
            // These settings must be defined as page fields, and must be of type Option or Enum. You cannot define groups in this area.
        }

        area(Content)
        {
            field("Project Tasks"; OutputProjectTasks)
            {
                MultiLine = true;
                ExtendedDatatype = RichContent;
                Editable = false;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                trigger OnAction()
                var
                    SystemPrompt: Text;
                begin
                    SystemPrompt := //'Describe the project in detail with tasks';
                    'The user will describe a project. Your task is to prepare the project plan for this project to be used in Microsoft Dynamics 365 Business Central.'
                        + 'The output should be html formatted bulleted list. '
                        + 'Generate at least 6 tasks.'
                        + 'Order the tasks in order of execution.'
                        + 'If a task needs an item format the item name with bold.'
                        + 'Add relevant emoji to each task.'
                        + 'If a tasks needs a person format task with underline.';
                        

                    OutputProjectTasks := CreateSuggestion(SystemPrompt, InputProjectDescription);
                end;
            }
        }
        area(PromptGuide)
        {
            action("AOrganizeEvent")
            {
                Caption = 'Organize an event';
                trigger OnAction()
                begin
                    InputProjectDescription += 'Plan for organizing a <project name> for the attendees of <event name>';
                end;
            }
        }
    }

    var
        InputProjectDescription: Text;
        OutputProjectTasks: Text;

    local procedure CreateSuggestion(SystemPrompt: Text; ProjectDescription: Text): Text
    var
        CopilotCapability: Codeunit "Copilot Capability";
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        maxhistory : Integer;
        metaprompt: SecretText;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"My Project Task Creation") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"My Project Task Creation", 'https://about:none');

        // If you are using managed resources, call this function:
        // NOTE: endpoint, deployment, and key are only used to verify that you have a valid Azure OpenAI subscription; we don't use them to generate the result
        // AzureOpenAI.SetManagedResourceAuthorization(Enum::"AOAI Model Type"::"Chat Completions",
        //     GetEndpoint(), GetDeployment(), GetApiKey());
        // If you are using your own Azure OpenAI subscription, call this function instead:
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", GetEndpoint(), GetDeployment(), GetApiKey());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"My Project Task Creation");

        AOAIChatCompletionParams.SetMaxTokens(800);
        AOAIChatCompletionParams.SetTemperature(0.7);

        metaprompt := Format('You are an AI assistant for business central');
        AOAIChatMessages.SetPrimarySystemMessage(metaprompt);

        AOAIChatMessages.AddSystemMessage(SystemPrompt);
        AOAIChatMessages.AddUserMessage(ProjectDescription);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        if (AOAIOperationResponse.IsSuccess()) then
            exit(AOAIChatMessages.GetLastMessage());

        exit('Error: ' + AOAIOperationResponse.GetError());
    end;

    local procedure GetApiKey()apikey: SecretText
    begin
        // Use your Azure Open AI secret key.
        // NOTE: Do not add the key in plain text. Instead, use Isolated Storage or other more secure ways.
        IsolatedStorage.Get('apikey', apikey);
        exit(apikey);
    end;

    local procedure GetDeployment() deploymentname: Text
    begin
        IsolatedStorage.Get('deploymentname', deploymentname);
        exit(deploymentname);
    end;

    local procedure GetEndpoint() endpoint: Text
    begin
        // Use your endpoint name from Azure Open AI here
        IsolatedStorage.Get('endpoint', endpoint);
        exit(endpoint);
    end;

}
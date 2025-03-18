pageextension 50000 ProjectListExtension extends "Job List"
{
    actions
    {
        addfirst(Prompting)
        {
            action("MyDraftWithCopilot")
            {
                ApplicationArea = All;
                Caption = 'Generate tasks';
                RunObject = Page "Generate Tasks";
            }
        }
    }
}
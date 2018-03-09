page 50100 MusslanBeerTime
{
    PageType = Card;

    trigger OnOpenPage();
    begin
        MusslanBeerTime.Run;
    end;

    var
        MusslanBeerTime : Codeunit MusslanBeerTime;
}
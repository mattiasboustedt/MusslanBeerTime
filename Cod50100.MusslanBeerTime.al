codeunit 50100 MusslanBeerTime
{
    trigger OnRun();
    begin
        GetMusslanBeerTime();
    end;
    
    local procedure GetMusslanBeerTime();
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        BeerObject: JsonObject;
        BeerToken: JsonToken;
        NanoToBeerTime: BigInteger;
        MusslanBeerTime: Boolean;
        BeerText: Text;
    begin
        if not HttpClient.Get('https://api.isitmusslanbeertime.com/time',Response) then
            Error('Call to WS failed.');
            
        if not Response.IsSuccessStatusCode then
            Error('Error:  %1\ Statuscode: %2',
                    Response.ReasonPhrase,
                    Format(Response.HttpStatusCode));
                    
        Response.Content.ReadAs(BeerText);
        BeerObject.ReadFrom(BeerText);
        
        MusslanBeerTime := IsItMusslanBeerTime(BeerObject);
        NanoToBeerTime := GetNanoToBeerTime(BeerObject);
        
        AlertUserOfBeerTime(MusslanBeerTime,NanoToBeerTime);
    end;
    
    local procedure IsItMusslanBeerTime(BeerObject: JsonObject) MusslanBeerTime: Boolean;
    begin
        MusslanBeerTime := GetJsonToken(BeerObject,'currentBeerTime').AsValue.AsBoolean;
    end;
    
    local procedure GetNanoToBeerTime(BeerObject: JsonObject) NanoToBeerTime: BigInteger;
    begin
        NanoToBeerTime := GetJsonToken(BeerObject,'nanoToBeerTime').AsValue.AsBigInteger;
    end;
    
    local procedure ConvertNanoToHours(NanoToBeerTime: BigInteger) HoursToBeerTime: Decimal
    var
        HoursToNanoRatio: Decimal;
    begin
        HoursToNanoRatio := 0.000000000000277778;
        HoursToBeerTime := HoursToNanoRatio * NanoToBeerTime;
        HoursToBeerTime := Round(HoursToBeerTime);
    end;
    
    local procedure AlertUserOfBeerTime(MusslanBeerTime: Boolean; NanoToBeerTime: BigInteger) Success: Boolean
    var
        HoursToBeerTime: Decimal;
        BeerMessage: Text;
    begin
        HoursToBeerTime := ConvertNanoToHours(NanoToBeerTime);
        
        if MusslanBeerTime = true then
            BeerMessage := 'It is Musslan Beer Time! Please stop whatever you are doing and grab a beer.'
        else
            BeerMessage := 'Unfortunately, it is not Musslan Beer Time.'
            + ' Nano To Beer Time: ' + Format(NanoToBeerTime) + '.'
            + ' Hours To Beer Time: ' + Format(HoursToBeerTime) + '.';
            
        Message(BeerMessage);
    end;
    
    local procedure GetJsonToken(BeerObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not BeerObject.Get(TokenKey,JsonToken) then
            Error('Could not find a token with key %1',TokenKey);
    end;
    
    [EventSubscriber(ObjectType::Codeunit,1,'OnAfterCompanyOpen','',false,false)]
    local procedure SendUserNotificationOnAfterCompanyOpen();
    var
        MusslanBeerTime: Codeunit MusslanBeerTime;
    begin
        MusslanBeerTime.Run;
    end;
    
}
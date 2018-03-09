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
        BeerText: text;
        MusslanBeerTime: Boolean;
        NanoToBeerTime: BigInteger;
    begin
        if not HttpClient.Get('https://api.isitmusslanbeertime.com/time', Response) then
            error('Call to WS failed.');

        if not Response.IsSuccessStatusCode then
            Error('Error:  %1\ Statuscode: %2',
                    Response.ReasonPhrase,
                    FORMAT(Response.HttpStatusCode));

        Response.Content.ReadAs(BeerText);
        BeerObject.ReadFrom(BeerText);

        MusslanBeerTime := IsItMusslanBeerTime(BeerObject);
        NanoToBeerTime := GetNanoToBeerTime(BeerObject);

        AlertUserOfBeerTime(MusslanBeerTime, NanoToBeerTime);
    end;

    local procedure IsItMusslanBeerTime(BeerObject: JsonObject) MusslanBeerTime: Boolean;
    begin
        MusslanBeerTime := GetJsonToken(BeerObject, 'currentBeerTime').AsValue.AsBoolean;
    end;

    local procedure GetNanoToBeerTime(BeerObject: JsonObject) NanoToBeerTime: BigInteger;
    begin
        NanoToBeerTime := GetJsonToken(BeerObject, 'nanoToBeerTime').AsValue.AsBigInteger;
    end;

    local procedure ConvertNanoToHours(NanoToBeerTime: BigInteger) HoursToBeerTime: BigInteger
    var
        HoursToNanoRatio: Decimal;

    begin
        HoursToNanoRatio := 0.000000000000277778;
        HoursToBeerTime := HoursToNanoRatio * NanoToBeerTime;
    end;

    local procedure AlertUserOfBeerTime(MusslanBeerTime: Boolean; NanoToBeerTime: BigInteger) Success: Boolean
    var
        UserNotification: Notification;
        BeerMessage: Text;
        HoursToBeerTime: BigInteger;
    begin
        HoursToBeerTime := ConvertNanoToHours(NanoToBeerTime);

        if MusslanBeerTime = TRUE then
            BeerMessage := 'It is Musslan Beer Time. Let us celebrate.'
        else
            BeerMessage := 'Unfortunately, it is not Musslan Beer Time.'
                            + ' Nano To Beer Time: ' + FORMAT(NanoToBeerTime) + '.'
                            + ' Hours To Beer Time: ' + FORMAT(HoursToBeerTime) + '.';

        UserNotification.Message(BeerMessage);
        UserNotification.Send;
    end;

    local procedure GetJsonToken(BeerObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not BeerObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

}
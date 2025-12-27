namespace CustomHUD
{
    /*
     * -------------------------------------------------------------------------
     * Constants & enumerators
     * -------------------------------------------------------------------------
     */

    /** @var int HUD channel for ticket counter. */
    const int TICKETS_HUD_CHANNEL = 1;

    /** @var string Entity name for ticket counter. */
    const string TICKETS_COUNTER_ENTITY_NAME = "ticket_counter";



    /*
     * -------------------------------------------------------------------------
     * Variables
     * -------------------------------------------------------------------------
     */

    /** @var bool g_fShowTickets [description] */
    bool g_fShowTickets;

    /** @var int g_iTickets [description] */
    int g_iTickets;

    /** @var int g_iTicketsTotal [description] */
    int g_iTicketsTotal;

    /** @var EHandle g_hTicketCounter [description] */
    EHandle g_hTicketCounter;



    /*
     * -------------------------------------------------------------------------
     * Life cycle functions
     * -------------------------------------------------------------------------
     */

    void Init()
    {
        g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);

        g_fShowTickets  = false;
        g_iTicketsTotal = 0;
        g_iTickets      = 0;
    }



    /*
     * -------------------------------------------------------------------------
     * Helper functions
     * -------------------------------------------------------------------------
     */



    /*
     * -------------------------------------------------------------------------
     * Functions
     * -------------------------------------------------------------------------
     */

    HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
    {
        if ( g_fShowTickets )
            SendTickets( pPlayer );

        return HOOK_CONTINUE;
    }

    void TicketStart()
    {
        CBaseEntity@ pEntity;

        @pEntity = g_EntityFuncs.FindEntityByTargetname( null, TICKETS_COUNTER_ENTITY_NAME );
        if ( pEntity is null )
            g_Game.AlertMessage( at_error, "Ticket counter entity '%1' not found\n", TICKETS_COUNTER_ENTITY_NAME );
        else
            g_hTicketCounter = EHandle( pEntity );

        g_Scheduler.SetInterval( "PeriodicUpdate", 0.5, g_Scheduler.REPEAT_INFINITE_TIMES );

        UpdateTickets();
        g_iTicketsTotal = g_iTickets;

        SendTickets( null );
    }

    void TicketEnd()
    {
        ToggleTicketsDisplay( false );
    }



    //-----------------------------------------------------------------------------
    // Purpose:
    //-----------------------------------------------------------------------------
    RGBA StringToRGBA( const string& in strColor )
    {
        RGBA rgba = RGBA_WHITE;
        array<string>@ strComp = strColor.Split( " " );
        if ( strComp.length() == 4 )
        {
            rgba.r = atoi( strComp[ 0 ] );
            rgba.g = atoi( strComp[ 1 ] );
            rgba.b = atoi( strComp[ 2 ] );
            rgba.a = atoi( strComp[ 3 ] );
        }

        return rgba;
    }

    //-----------------------------------------------------------------------------
    // Purpose:
    //-----------------------------------------------------------------------------
    void Message( CBasePlayer@ pPlayer, const string& in text, float x = -1, float y = -1,
        RGBA color = RGBA_WHITE, float fin = 0.5, float fout = 0.5, float hold = 5.0 )
    {
        HUDTextParams txtPrms;

        txtPrms.x = x;
        txtPrms.y = y;
        txtPrms.effect = 0;

        txtPrms.r1 = txtPrms.r2 = color.r;
        txtPrms.g1 = txtPrms.g2 = color.g;
        txtPrms.b1 = txtPrms.b2 = color.b;
        txtPrms.a1 = txtPrms.a2 = color.a;

        txtPrms.fadeinTime = fin;
        txtPrms.fadeoutTime = fout;
        txtPrms.holdTime = hold;
        txtPrms.fxTime = 0;//0.25f;
        txtPrms.channel = 2;

        if ( pPlayer !is null )
            g_PlayerFuncs.HudMessage( pPlayer, txtPrms, text );
        else
            g_PlayerFuncs.HudMessageAll( txtPrms, text );
    }

    //=============================================================================
    // Tickets
    //=============================================================================

    //-----------------------------------------------------------------------------
    // Purpose:
    //-----------------------------------------------------------------------------
    void UpdateTickets()
    {
        if ( !g_hTicketCounter.IsValid() )
                return;

        CBaseEntity@ pEntity = g_hTicketCounter;
        g_iTickets = int( pEntity.pev.frags );
    }

    int g_iLastTickets = -1;

    //-----------------------------------------------------------------------------
    // Purpose:
    //-----------------------------------------------------------------------------
    void PeriodicUpdate()
    {
        if ( g_fShowTickets )
        {
            UpdateTickets();

            if ( g_iLastTickets != g_iTickets )
            {
                SendTickets( null );
                g_iLastTickets = g_iTickets;
            }
        }
    }

    //-----------------------------------------------------------------------------
    // Purpose:
    //-----------------------------------------------------------------------------
    void SendTickets( CBasePlayer@ pPlayer )
    {
        g_fShowTickets = true;

        HUDNumDisplayParams params;

        params.channel = TICKETS_HUD_CHANNEL;
        params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA;
        params.value = g_iTickets;
        params.x = 0;
        params.y = 1;
        params.defdigits = 3;
        params.maxdigits = 3;
        params.color1 = g_iTickets <= 1 ? RGBA_RED : RGBA_SVENCOOP;
        params.spritename = "ragemap2023/tickets.spr";

        g_PlayerFuncs.HudNumDisplay( pPlayer, params );
    }

    //-----------------------------------------------------------------------------
    // Purpose:
    //-----------------------------------------------------------------------------
    void ToggleTicketsDisplay( bool fVisible )
    {
        /*if ( g_fShowTickets == fVisible )
            return;*/

        g_fShowTickets = fVisible;

        if ( g_fShowTickets )
        {
            SendTickets( null );
        }
        else
        {
            g_PlayerFuncs.HudToggleElement( null, TICKETS_HUD_CHANNEL, false );
        }
    }
}

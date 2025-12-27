/*
 * Credits Controller Script (HUD Version)
 * Handles fading sprites and text for the outro sequence.
 */

namespace Ragemap2025Credits
{
    const float FADE_IN_TIME  = 0.4f; 
    const float FADE_OUT_TIME = 0.4;
    const float HOLD_TIME     = 9999.0f;
    
    const int CHAN_MAIN_PIC = 14; 
    const int CHAN_ICON     = 13; 
    const int CHAN_TEXT     = 3;

    // Vertical offset for the Icon (Logo). 
    // Negative moves UP.
    const int ICON_OFFSET_Y   = -224; 

    // Track which credit is currently showing
    int g_iCurrentActive = -1;

    // Sprite Offsets (X, Y) in Pixels
    // These move the Main Sprite AND the Icon together.
    const array<Vector2D> g_SpriteOffsets = {
        Vector2D( 0, 0 ),    // Index 0: Grunt
        Vector2D( 0, 0 ),    // Index 1: Hezus
        Vector2D( 0, 0 ),    // Index 2: Fn
        Vector2D( 0, 0 ),    // Index 3: Bonk
        Vector2D( 0, 0 )     // Index 4: Thanks
    };

    class CreditEntry
    {
        string mainSprite;
        string iconSprite;
        string textLine;
        float textX;
        float textY;

        CreditEntry() {} 
        CreditEntry( string main, string icon, string txt, float tx, float ty )
        {
            mainSprite = main;
            iconSprite = icon;
            textLine = txt;
            textX = tx;
            textY = ty;
        }
    }

    const array<CreditEntry> g_Credits = {
        // Index 0: Grunt
        CreditEntry( 
            "ragemap2025/credits/credits_grunt.spr", 
            "ragemap2025/channelicon_grunt.spr", 
            "Grunt - M.U.L.E Escort", 
            -1, 0.65
        ),
        // Index 1: Hezus
        CreditEntry( 
            "ragemap2025/credits/credits_hezus.spr", 
            "ragemap2025/channelicon_hezus.spr", 
            "Hezus - Beach Fever", 
            -1, 0.65
        ),
        // Index 2: Fn
        CreditEntry( 
            "ragemap2025/credits/credits_fn.spr", 
            "ragemap2025/channelicon_fn.spr", 
            "FourNines - Smell of Asphalt", 
            -1, 0.65
        ),
        // Index 3: Bonk
        CreditEntry( 
            "ragemap2025/credits/credits_bonk.spr", 
            "ragemap2025/channelicon_bonk.spr", 
            "BonkTurnip - Crab Invasion", 
            -1, 0.65
        ),
        // Index 4: Thanks
        CreditEntry( 
            "ragemap2025/credits/credits_thanks.spr", 
            "", 
            "", 
            -1, 0.65
        )
    };

    void MapInit()
    {
        for( uint i = 0; i < g_Credits.length(); i++ )
        {
            g_Game.PrecacheModel( "sprites/" + g_Credits[i].mainSprite );
            
            if( !g_Credits[i].iconSprite.IsEmpty() )
            {
                g_Game.PrecacheModel( "sprites/" + g_Credits[i].iconSprite );
            }
        }
        g_Game.AlertMessage( at_console, "Ragemap2025Credits: Initialized.\n" );
    }

    /**
     * Show a credit entry.
     */
    void Show( int index )
    {
        if( index < 0 || index >= int(g_Credits.length()) ) return;

        g_iCurrentActive = index;
        const CreditEntry@ c = g_Credits[index];
        
        // Retrieve offset from the separate array
        Vector2D offset = g_SpriteOffsets[index];

        HUDSpriteParams pMain;
        pMain.channel = CHAN_MAIN_PIC;
        pMain.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_ABSOLUTE_X | HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_NO_BORDER | HUD_SPR_MASKED;
        pMain.x = offset.x; 
        pMain.y = offset.y;
        pMain.spritename = c.mainSprite;
        pMain.fadeinTime = FADE_IN_TIME;
        pMain.fadeoutTime = FADE_OUT_TIME;
        pMain.holdTime = HOLD_TIME;
        pMain.color1 = RGBA(255, 255, 255, 255); 

        HUDSpriteParams pIcon;
        bool bHasIcon = !c.iconSprite.IsEmpty();
        
        if( bHasIcon )
        {
            pIcon.channel = CHAN_ICON;
            pIcon.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_ABSOLUTE_X | HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_NO_BORDER | HUD_SPR_MASKED;
            pIcon.x = offset.x; 
            pIcon.y = offset.y + ICON_OFFSET_Y; 
            pIcon.spritename = c.iconSprite;
            pIcon.fadeinTime = FADE_IN_TIME;
            pIcon.fadeoutTime = FADE_OUT_TIME;
            pIcon.holdTime = HOLD_TIME;
            pIcon.color1 = RGBA(255, 255, 255, 255); 
        }

        HUDTextParams pText;
        pText.x = c.textX;
        pText.y = c.textY;
        pText.effect = 0;
        pText.r1 = 255; pText.g1 = 255; pText.b1 = 255; pText.a1 = 255;
        pText.r2 = 100; pText.g2 = 255; pText.b2 = 100; pText.a2 = 255;
        pText.fadeinTime = FADE_IN_TIME;
        pText.fadeoutTime = FADE_OUT_TIME;
        pText.holdTime = HOLD_TIME;
        pText.channel = CHAN_TEXT;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                // Order matters for layering!
                g_PlayerFuncs.HudCustomSprite( pPlayer, pMain ); // Bottom
                g_PlayerFuncs.HudMessage( pPlayer, pText, c.textLine ); // Middle
                
                if( bHasIcon )
                {
                    g_PlayerFuncs.HudCustomSprite( pPlayer, pIcon ); // Top
                }
            }
        }
    }

    /**
     * Hide all credit elements gracefully.
     */
    void Hide()
    {
        if( g_iCurrentActive < 0 || g_iCurrentActive >= int(g_Credits.length()) ) return;

        const CreditEntry@ c = g_Credits[g_iCurrentActive];
        Vector2D offset = g_SpriteOffsets[g_iCurrentActive];

        HUDSpriteParams pMainFade;
        pMainFade.channel = CHAN_MAIN_PIC;
        pMainFade.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_ABSOLUTE_X | HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_NO_BORDER | HUD_SPR_MASKED;
        pMainFade.x = offset.x; 
        pMainFade.y = offset.y;
        pMainFade.spritename = c.mainSprite; 
        pMainFade.fadeinTime = 0; 
        pMainFade.holdTime = 0;   
        pMainFade.fadeoutTime = FADE_OUT_TIME;
        pMainFade.color1 = RGBA(255, 255, 255, 255); 

        HUDSpriteParams pIconFade;
        bool bHasIcon = !c.iconSprite.IsEmpty();

        if( bHasIcon )
        {
            pIconFade.channel = CHAN_ICON;
            pIconFade.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_ABSOLUTE_X | HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_NO_BORDER | HUD_SPR_MASKED;
            pIconFade.x = offset.x; 
            pIconFade.y = offset.y + ICON_OFFSET_Y; 
            pIconFade.spritename = c.iconSprite; 
            pIconFade.fadeinTime = 0;
            pIconFade.holdTime = 0;
            pIconFade.fadeoutTime = FADE_OUT_TIME;
            pIconFade.color1 = RGBA(255, 255, 255, 255);
        }

        HUDTextParams pTextFade;
        pTextFade.channel = CHAN_TEXT;
        pTextFade.x = c.textX;
        pTextFade.y = c.textY;
        pTextFade.effect = 0;
        pTextFade.r1 = 255; pTextFade.g1 = 255; pTextFade.b1 = 255; pTextFade.a1 = 255;
        pTextFade.fadeinTime = 0;
        pTextFade.holdTime = 0;
        pTextFade.fadeoutTime = FADE_OUT_TIME;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                g_PlayerFuncs.HudCustomSprite( pPlayer, pMainFade );
                if( bHasIcon ) g_PlayerFuncs.HudCustomSprite( pPlayer, pIconFade );
                g_PlayerFuncs.HudMessage( pPlayer, pTextFade, c.textLine );
            }
        }

        g_iCurrentActive = -1;
    }
}

// Grunt (Index 0)
void credits_script_grunt_on( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Show( 0 ); }
void credits_script_grunt_off( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Hide(); }

// Hezus (Index 1)
void credits_script_hezus_on( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Show( 1 ); }
void credits_script_hezus_off( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Hide(); }

// Fn (Index 2)
void credits_script_fn_on( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Show( 2 ); }
void credits_script_fn_off( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Hide(); }

// Bonk (Index 3)
void credits_script_bonk_on( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Show( 3 ); }
void credits_script_bonk_off( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Hide(); }

// Thanks (Index 4)
void credits_script_thanks_on( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Show( 4 ); }
void credits_script_thanks_off( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue ) { Ragemap2025Credits::Hide(); }
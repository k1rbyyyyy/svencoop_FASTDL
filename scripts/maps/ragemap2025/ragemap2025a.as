/*============================================*/
/*==== Ragemap 2025 map A script - v 1.00 ====*/
/*============================================*/



/*
 * -------------------------------------------------------------------------
 * Includes
 * -------------------------------------------------------------------------
 */

#include "ragemap2025"
#include "fournines/weapon_dxnanosword"
#include "grunt"
#include "credits"

/*
 * -------------------------------------------------------------------------
 * Life cycle functions
 * -------------------------------------------------------------------------
 */

/**
 * Map initialisation handler.
 * @return void
 */
/* ragemap2025a.as */

void MapInit()
{
    // Shared script
    Ragemap2025::MapInit();

    // Four-Nines' script
    DX_NANOSWORD::Register();

    // Grunt's script
    Ragemap2025Grunt::MapInit();

    // Credit script
    Ragemap2025Credits::MapInit();
}

/**
 * Map activation handler.
 * @return void
 */
void MapActivate()
{
    // Shared script
    Ragemap2025::MapActivate();
}

#include "grunt/base"
#include "grunt/vectorUtils"
#include "grunt/weapon_ns_machinegun"
#include "grunt/weapon_ns_pistol"
#include "grunt/weapon_ns_shotgun"
#include "grunt/weapon_ns_grenade"
#include "grunt/weapon_ns_heavymachinegun"
#include "grunt/monster_skulk"
#include "grunt/monster_fade"

namespace Ragemap2025Grunt
{
    void MapInit()
    {
        NS_MACHINEGUN::Register();
        NS_PISTOL::Register();
        NS_SHOTGUN::Register();
        NS_GRENADE::Register();
        NS_HEAVYMACHINEGUN::Register();
        NS_SKULK::Register();
        NS_FADE::Register();
    }
}

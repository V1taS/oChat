/* SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright © 2022 The TokTok team.
 */

#include "../Headers/tox_pack.h"

#include <stdint.h>

#include "../Headers/bin_pack.h"
#include "../Headers/tox.h"

bool tox_conference_type_pack(Tox_Conference_Type val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_connection_pack(Tox_Connection val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_file_control_pack(Tox_File_Control val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_message_type_pack(Tox_Message_Type val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_user_status_pack(Tox_User_Status val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_group_privacy_state_pack(Tox_Group_Privacy_State val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_group_voice_state_pack(Tox_Group_Voice_State val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_group_topic_lock_pack(Tox_Group_Topic_Lock val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_group_join_fail_pack(Tox_Group_Join_Fail val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_group_mod_event_pack(Tox_Group_Mod_Event val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}
bool tox_group_exit_type_pack(Tox_Group_Exit_Type val, Bin_Pack *bp)
{
    return bin_pack_u32(bp, (uint32_t)val);
}

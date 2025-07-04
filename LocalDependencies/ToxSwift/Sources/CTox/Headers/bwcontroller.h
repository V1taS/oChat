/* SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright © 2016-2018 The TokTok team.
 * Copyright © 2013-2015 Tox project.
 */
#ifndef C_TOXCORE_TOXAV_BWCONTROLLER_H
#define C_TOXCORE_TOXAV_BWCONTROLLER_H

#include <stdint.h>

#include "logger.h"
#include "mono_time.h"
#include "tox.h"

typedef struct BWController BWController;

typedef void m_cb(BWController *bwc, uint32_t friend_number, float loss, void *user_data);

BWController *bwc_new(const Logger *log, Tox *tox, uint32_t friendnumber,
                      m_cb *mcb, void *mcb_user_data, Mono_Time *bwc_mono_time);

void bwc_kill(BWController *bwc);

void bwc_add_lost(BWController *bwc, uint32_t bytes_lost);
void bwc_add_recv(BWController *bwc, uint32_t recv_bytes);
void bwc_allow_receiving(Tox *tox);
void bwc_stop_receiving(Tox *tox);

#endif /* C_TOXCORE_TOXAV_BWCONTROLLER_H */

/************************************************************************/
/*  Mupen64API.vala                                                     */
/************************************************************************/
/*                       This file is part of:                          */
/*                           MupenGUI                                   */
/*               https://github.com/efdos/mupengui                      */
/************************************************************************/
/* Copyright (c) 2018 Douglas Muratore                                  */
/*                                                                      */
/* This program is free software; you can redistribute it and/or        */
/* modify it under the terms of the GNU General Public                  */
/* License as published by the Free Software Foundation; either         */
/* version 2 of the License, or (at your option) any later version.     */
/*                                                                      */
/* This program is distributed in the hope that it will be useful,      */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    */
/* General Public License for more details.                             */
/*                                                                      */
/* You should have received a copy of the GNU General Public            */
/* License along with this program; if not, write to the                */
/* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,     */
/* Boston, MA 02110-1301 USA                                            */
/*                                                                      */
/* Authored by: Douglas Muratore <www.sinz.com.br>                      */
/************************************************************************/

/*****************
 * Mupen64 C API *
 *****************/
extern int m64_load_corelib ();
extern int m64_unload_corelib ();
extern int m64_start_corelib (char* pconfig_path, char* pdata_path);
extern int m64_shutdown_corelib ();
extern int m64_command (int command, int param_int, void* param_ptr);
extern void m64_set_verbose (bool b);

namespace MupenGUI.Services {
    class Mupen64API : Object {

        public enum m64Command {
            NOP = 0,
            ROM_OPEN,
            ROM_CLOSE,
            ROM_GET_HEADER,
            ROM_GET_SETTINGS,
            EXECUTE,
            STOP,
            PAUSE,
            RESUME,
            CORE_STATE_QUERY,
            STATE_LOAD,
            STATE_SAVE,
            STATE_SET_SLOT,
            SEND_SDL_KEYDOWN,
            SEND_SDL_KEYUP,
            SET_FRAME_CALLBACK,
            TAKE_NEXT_SCREENSHOT,
            CORE_STATE_SET,
            READ_SCREEN,
            RESET,
            ADVANCE_FRAME
        }

        private static Mupen64API _instance = null;
        private bool initialized = false;

        public static Mupen64API instance {
            get {
                if (_instance == null) {
                    _instance = new Mupen64API ();
                }

                return _instance;
            }
        }

        private Mupen64API () {
            // do nothing for now
        }

        ~Mupen64API ()
        {
            shutdown ();
        }

        public bool init () {
            var result = m64_load_corelib ();
            if (result == 0) {
                stderr.printf ("Info: Mupen64Plus Dynamic Library Loaded.\n");
            } else {
                stderr.printf ("Error: Failed to load Mupen64Plus Dynamic Library. Error code: %d\n", result);
                return false;
            }

            result = m64_start_corelib (null, null);
            if (result == 0) {
                stderr.printf ("Info: Mupen64Plus Core Initialized.\n");
            } else {
                stderr.printf ("Error: Failed to initialize Mupen64Plus Core. Error code: %d\n", result);
                return false;
            }

            return initialized = true;
        }

        public void shutdown () {
            var result = m64_shutdown_corelib ();
            if (result != 0) {
                stderr.printf ("Error: Failed to shut down Mupen64Plus Core. Error code: %d\n", result);
            }

            result = m64_unload_corelib ();
            if (result != 0) {
                stderr.printf ("Error: Failed to unload Mupen64Plus Dynamic Library. Error code: %d\n", result);
            }

            initialized = false;
        }

        public bool run_command (m64Command command, int param_int = 0, void* param_ptr = null) {
            var result = m64_command (command, param_int, param_ptr);
            if (result != 0) {
                stderr.printf ("Error: Failed to run command: %d (%d, %p)\n", command, param_int, param_ptr);
                stderr.printf ("Error code: %d", result);
                return false;
            }
            return true;
        }

        public void set_verbose (bool b) {
            m64_set_verbose (b);
        }
    }
}
/*
 * Copyright (C) 2010 Collabora Ltd.
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *       Philip Withnall <philip.withnall@collabora.co.uk>
 */

using GLib;
using Gee;

/**
 * Manage debug output and status reporting for all folks objects. All GLib
 * debug logging calls are passed through a log handler in this class, which
 * allows debug domains to be outputted according to whether they've been
 * enabled by being passed to {@link Debug.dup}.
 *
 * @since UNRELEASED
 */
public class Folks.Debug : Object
{
  private enum Domains {
    /* Zero is used for "no debug spew" */
    CORE = 1 << 0,
    TELEPATHY_BACKEND = 1 << 1,
    KEY_FILE_BACKEND = 1 << 2
  }

  private static weak Debug _instance; /* needs to be locked when accessed */
  private HashSet<string> _domains;
  private bool _all = false;

  /* turn off debug output for the given domain unless it was in the FOLKS_DEBUG
   * environment variable (or 'all' was set) */
  internal void _register_domain (string domain)
    {
      if (this._all || this._domains.contains (domain.down ()))
        {
          /* FIXME: shouldn't need to cast. See bgo#638682 */
          Log.set_handler (domain, LogLevelFlags.LEVEL_MASK,
              (LogFunc) Log.default_handler);
          return;
        }

      /* Install a log handler which will blackhole the log message.
       * Other log messages will be printed out by the default log handler. */
      Log.set_handler (domain, LogLevelFlags.LEVEL_DEBUG,
          (domain_arg, flags, message) => {});
    }

  /**
   * Create or return the singleton {@link Debug} class instance.
   * If the instance doesn't exist already, it will be created with the given
   * set of debug domains enabled. Otherwise, the existing instance will have
   * its set of enabled domains changed to the provided set.
   *
   * This function is thread-safe.
   *
   * @param debug_flags	A comma-separated list of debug domains to enable,
   *			or null to disable debug output
   * @return		Singleton {@link Debug} instance
   * @since UNRELEASED
   */
  public static Debug dup (string? debug_flags)
    {
      lock (Debug._instance)
        {
          var retval = Debug._instance;

          if (retval == null)
            {
              /* use an intermediate variable to force a strong reference */
              retval = new Debug ();
              Debug._instance = retval;
            }

          retval._all = false;
          retval._domains = new HashSet<string> (str_hash, str_equal);

          if (debug_flags != null && debug_flags != "")
            {
              var domains_split = debug_flags.split (",");
              foreach (var domain in domains_split)
                {
                  var domain_lower = domain.down ();

                  if (GLib.strcmp (domain_lower, "all") == 0)
                    retval._all = true;
                  else
                    retval._domains.add (domain_lower);
                }
            }

          return retval;
        }
    }

  private Debug ()
    {
      /* Private constructor for singleton */
    }

  ~Debug ()
    {
      /* Manually clear the singleton _instance */
      lock (Debug._instance)
        {
          Debug._instance = null;
        }
    }
}

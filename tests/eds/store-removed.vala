/*
 * Copyright (C) 2011 Philip Withnall
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
 * Authors: Philip Withnall <philip@tecnocode.co.uk>
 *
 */

using EdsTest;
using Folks;
using Gee;

public class StoreRemovedTests : Folks.TestCase
{
  private EdsTest.Backend _eds_backend;
  private GLib.MainLoop _main_loop;
  private IndividualAggregator _aggregator;

  public StoreRemovedTests ()
    {
      base ("StoreRemoved");

      this._eds_backend = new EdsTest.Backend ();

      this.add_test ("single store", this.test_single_store);
    }

  public override void set_up ()
    {
      this._eds_backend.set_up ();
    }

  public override void tear_down ()
    {
      this._eds_backend.tear_down ();
    }

  public void test_single_store ()
    {
      this._main_loop = new GLib.MainLoop (null, false);

      this._eds_backend.reset ();

      /* Create a contact in the address book. */
      var c1 = new Gee.HashMap<string, Value?> ();

      Value? v = Value (typeof (string));
      v.set_string ("Chancellor Brian Blessed");
      c1.set ("full_name", (owned) v);

      v = Value (typeof (string));
      v.set_string ("brian@example.com");
      c1.set (Edsf.Persona.email_fields[0], (owned) v);

      this._eds_backend.add_contact (c1);

      /* Schedule the test to start with the main loop. */
      this._test_single_store_part1_async ();

      var timeout_id = Timeout.add_seconds (5, () =>
        {
          critical ("Timeout reached.");
          return false;
        });

      this._main_loop.run ();

      /* We should have a single individual by now. */
      assert (this._aggregator.individuals.size == 1);

      Source.remove (timeout_id);

      /* Part 2, where we remove the address book. */
      this._test_single_store_part2_async ();

      timeout_id = Timeout.add_seconds (5, () =>
        {
          critical ("Timeout reached.");
          return false;
        });

      this._main_loop.run ();

      /* The individual should be gone. */
      assert (this._aggregator.individuals.size == 0);

      Source.remove (timeout_id);
    }

  private async void _test_single_store_part1_async ()
    {
      yield this._eds_backend.commit_contacts_to_addressbook ();

      var store = BackendStore.dup ();
      yield store.prepare ();

      this._aggregator = new IndividualAggregator ();

      ulong signal_id = 0;
      signal_id = this._aggregator.individuals_changed_detailed.connect (
          (changes) =>
        {
          var added = changes.get_values ();
          var removed = changes.get_keys ();

          assert (added.size == 1);

          /* We don't really care what the individual is, as long as it's not
           * null. */
          foreach (var i in added)
            {
              assert (i != null);
            }

          assert (removed.size == 1);

          foreach (var i in removed)
            {
              assert (i == null);
            }

          /* Success! */
          this._main_loop.quit ();
          this._aggregator.disconnect (signal_id);
        });

      try
        {
          yield this._aggregator.prepare ();
        }
      catch (GLib.Error e)
        {
          critical ("Error when calling prepare: %s", e.message);
        }
    }

  private async void _test_single_store_part2_async ()
    {
      ulong signal_id = 0;
      signal_id = this._aggregator.individuals_changed_detailed.connect (
          (changes) =>
        {
          var added = changes.get_values ();
          var removed = changes.get_keys ();

          assert (added.size == 1);

          foreach (var i in added)
            {
              assert (i == null);
            }

          assert (removed.size == 1);

          /* We don't really care what the individual is, as long as it's not
           * null. */
          foreach (var i in removed)
            {
              assert (i != null);
            }

          /* Success! */
          this._main_loop.quit ();
          this._aggregator.disconnect (signal_id);
        });

      /* Tear down the backend. This should remove all individuals. We check
       * for this above. */
      E.SourceList? source_list = null;
      try
        {
          E.BookClient.get_sources (out source_list);
          source_list.remove_source_by_uid (this._eds_backend.address_book_uid);
        }
      catch (GLib.Error e1)
        {
          critical ("Error getting source list: %s", e1.message);
        }
    }
}

public int main (string[] args)
{
  Test.init (ref args);

  TestSuite root = TestSuite.get_root ();
  root.add_suite (new StoreRemovedTests ().get_suite ());

  Test.run ();

  return 0;
}
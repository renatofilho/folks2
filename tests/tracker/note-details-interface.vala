/*
 * Copyright (C) 2011 Collabora Ltd.
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
 * Authors: Raul Gutierrez Segales <raul.gutierrez.segales@collabora.co.uk>
 *
 */

using Tracker.Sparql;
using TrackerTest;
using Folks;
using Gee;

public class NoteDetailsInterfaceTests : Folks.TestCase
{
  private GLib.MainLoop _main_loop;
  private IndividualAggregator _aggregator;
  private TrackerTest.Backend _tracker_backend;
  private bool _found_note;
  private string _note;
  private string _fullname = "persona #1";

  public NoteDetailsInterfaceTests ()
    {
      base ("NoteDetailsInterfaceTests");

      this._tracker_backend = new TrackerTest.Backend ();
      this._tracker_backend.debug = false;

      this.add_test ("test note details interface",
          this.test_note_details_interface);
    }

  public override void set_up ()
    {
    }

  public override void tear_down ()
    {
    }

  public void test_note_details_interface ()
    {
      this._main_loop = new GLib.MainLoop (null, false);
      Gee.HashMap<string, string> c1 = new Gee.HashMap<string, string> ();
      this._fullname = "persona #1";
      this._note = "this is a note";

      c1.set (Trf.OntologyDefs.NCO_FULLNAME, this._fullname);
      c1.set (Trf.OntologyDefs.NCO_NOTE, this._note);
      this._tracker_backend.add_contact (c1);

      this._tracker_backend.set_up ();

      this._found_note = false;

      this._test_note_details_interface_async ();

      Timeout.add_seconds (5, () =>
        {
          this._main_loop.quit ();
          assert_not_reached ();
        });

      this._main_loop.run ();

      assert (this._found_note == true);

      this._tracker_backend.tear_down ();
    }

  private async void _test_note_details_interface_async ()
    {
      var store = BackendStore.dup ();
      yield store.prepare ();
      this._aggregator = new IndividualAggregator ();
      this._aggregator.individuals_changed.connect
          (this._individuals_changed_cb);
      try
        {
          yield this._aggregator.prepare ();
        }
      catch (GLib.Error e)
        {
          GLib.warning ("Error when calling prepare: %s\n", e.message);
        }
    }

  private void _individuals_changed_cb
      (Set<Individual> added,
       Set<Individual> removed,
       string? message,
       Persona? actor,
       GroupDetails.ChangeReason reason)
    {
      foreach (var i in added)
        {
          if (i.full_name == this._fullname)
            {
              i.notify["notes"].connect (this._notify_note_cb);
              foreach (var n in i.notes)
                {
                  if (n.equal (new NoteFieldDetails (this._note)))
                    {
                      this._found_note = true;
                      this._main_loop.quit ();
                    }
                }
            }
        }

      assert (removed.size == 0);
    }

  void _notify_note_cb (Object individual_obj, ParamSpec ps)
    {
      Folks.Individual individual = (Folks.Individual) individual_obj;
      foreach (var n in individual.notes)
        {
          if (n.equal (new NoteFieldDetails (this._note)))
            {
              this._found_note = true;
              this._main_loop.quit ();
            }
        }
    }
}

public int main (string[] args)
{
  Test.init (ref args);

  TestSuite root = TestSuite.get_root ();
  root.add_suite (new NoteDetailsInterfaceTests ().get_suite ());

  Test.run ();

  return 0;
}

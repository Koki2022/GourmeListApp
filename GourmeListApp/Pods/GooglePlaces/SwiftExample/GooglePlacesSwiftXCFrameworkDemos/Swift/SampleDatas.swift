// Copyright 2020 Google LLC. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.

import UIKit

struct Sample {
    let viewControllerClass: UIViewController.Type

    let title: String
}

struct Section {
    let name: String
    let samples: [Sample]
}

enum Samples {

    static func allSwiftSamples() -> [Section] {
        let autoCompleteSample: [Sample] = [
            Sample(
                viewControllerClass: AutocompletePushViewController.self,
                title: NSLocalizedString(
                    "Demo.Title.Autocomplete.Push",
                    comment: "Title of the pushed autocomplete demo for display in a list or nav header")),
            Sample(
                viewControllerClass: AutocompleteModalViewController.self,
                title: NSLocalizedString(
                    "Demo.Title.Autocomplete.FullScreen",
                    comment:
                        "Title of the full-screen autocomplete demo for display in a list or nav header")
            ),
            Sample(
                viewControllerClass: AutocompleteWithCustomColors.self,
                title: NSLocalizedString(
                    "Demo.Title.Autocomplete.Styling",
                    comment: "Title of the Styling autocomplete demo for display in a list or nav header")
            ),
            Sample(
                viewControllerClass: AutocompleteWithSearchViewController.self,
                title: NSLocalizedString(
                    "Demo.Title.Autocomplete.UISearchController",
                    comment:
                        "Title of the UISearchController autocomplete demo for display in a list or nav header"
                )
            ),
            Sample(
                viewControllerClass: AutocompleteWithTextFieldController.self,
                title: NSLocalizedString(
                    "Demo.Title.Autocomplete.UITextField",
                    comment:
                        "Title of the UITextField autocomplete demo for display in a list or nav header")
            )
        ]
        let likelihoodsSample: [Sample] = [
            Sample(
                viewControllerClass: FindPlaceLikelihoodListViewController.self,
                title: "Find Place Likelihoods")
        ]

        var sections = [
            Section(name: "Autocomplete", samples: autoCompleteSample),
            Section(name: "Likelihoods", samples: likelihoodsSample)
        ]
        let textSearchSample: [Sample] = [
            Sample(
                viewControllerClass: TextSearchViewController.self,
                title: NSLocalizedString(
                    "Demo.Section.Title.TextSearch",
                    comment:
                        "Title of the textSearch demo section"))
        ]
        let textSearchSection = Section(
            name: NSLocalizedString(
                "Demo.Section.Title.TextSearch",
                comment:
                    "Title of the textSearch demo section"), samples: textSearchSample)
        sections.append(textSearchSection)
        let searchNearbySample: [Sample] = [
            Sample(
                viewControllerClass: SearchNearbyViewController.self,
                title: NSLocalizedString(
                    "Demo.Section.Title.SearchNearby",
                    comment:
                        "Title of the searchNearby demo section"))
        ]
        let searchNearbySection = Section(
            name: NSLocalizedString(
                "Demo.Section.Title.SearchNearby",
                comment:
                    "Title of the searchNearby demo section"), samples: searchNearbySample)
        sections.append(searchNearbySection)

        return sections
    }
}

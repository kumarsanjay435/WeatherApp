//
//  SearchLocationView.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import SwiftUI

struct SearchLocationView: View {
    
    // MARK: - Variables
    @ObservedObject var viewModel: SearchLocationViewModel
    
    // MARK: - Views
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            LinearGradient(gradient: Gradient(colors: [Color("BackgroundTop"), Color("BackgroundBottom")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        if(!viewModel.searchBarVM.searchOpened) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                                viewModel.searchBarVM.searchOpened.toggle()
                            }
                        }
                    } label: {
                        SearchBarView(expandSearchbar: $viewModel.searchBarVM.searchOpened, searchText: $viewModel.query, searchBarVM: viewModel.searchBarVM)
                    }
                    .animation(.spring(), value: viewModel.searchBarVM.searchOpened)
                    .buttonStyle(.plain)
                    .frame(width: UIScreen.main.bounds.width - 48)
                }
                .padding(.top, 16)
                .padding(.leading, 16)
                Spacer()
            }
            
            VStack(spacing: 44) {
                switch viewModel.state {
                case .loaded(let locations):
                    ForEach(locations) { location in
                        HStack {
                            Text(location.name)
                                .font(Montserrat.bold.font(size: 26))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    viewModel.selectLocation(location)
                                }
                        }
                    }
                case .error(let errorMessage):
                    HStack {
                        Text("\(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                case .loading:
                    ProgressView("Fetching locations...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .foregroundColor(.white)
                        .padding()
                case .notStarted:
                    EmptyView()
                }
            }
            .padding(.leading, 16)
            .padding(.top, 172)
        }
    }
}

struct SearchLocationView_Previews: PreviewProvider {
    static var previews: some View {
        SearchLocationView(viewModel: SearchLocationViewModel(coordinator: WeatherCoordinator()))
            .environment(\.colorScheme, .light) // Light mode
        SearchLocationView(viewModel: SearchLocationViewModel(coordinator: WeatherCoordinator()))
            .environment(\.colorScheme, .dark) // Dark mode
    }
}
